#!/usr/bin/env python3
"""
Comprehensive Backend API Testing for Enhanced Theme System
Tests all Theme API endpoints with realistic data and validation
"""

import requests
import json
import os
import time
from datetime import datetime, timedelta
import uuid

# Configuration
BASE_URL = "http://localhost:3001/api"

# Valid theme values for testing
VALID_THEMES = [
    'darkClassic', 'lightClassic', 'darkNeon', 'lightPastel', 
    'darkPurple', 'lightGreen', 'darkOrange', 'lightBlue'
]

# Invalid theme values for testing
INVALID_THEMES = [
    'invalidTheme', 'dark', 'light', 'neon', 'purple', 
    'green', 'orange', 'blue', '', 123, True
]

# Test data for theme testing
TEST_USERS = [
    {
        "username": "theme_user_alice",
        "email": "alice.theme@example.com", 
        "password": "ThemeTest123",
        "displayName": "Alice Theme Tester"
    },
    {
        "username": "theme_user_bob",
        "email": "bob.theme@example.com",
        "password": "ThemeTest456", 
        "displayName": "Bob Theme Tester"
    },
    {
        "username": "theme_user_carol",
        "email": "carol.theme@example.com",
        "password": "ThemeTest789",
        "displayName": "Carol Theme Tester"
    }
]

class ThemeBackendTester:
    def __init__(self):
        self.session = requests.Session()
        self.users = {}
        self.test_results = []
        
    def log_result(self, test_name, success, message, details=None):
        """Log test result"""
        result = {
            "test": test_name,
            "success": success,
            "message": message,
            "timestamp": datetime.now().isoformat(),
            "details": details
        }
        self.test_results.append(result)
        status = "✅ PASS" if success else "❌ FAIL"
        print(f"{status}: {test_name} - {message}")
        if details and not success:
            print(f"   Details: {details}")
    
    def test_health_check(self):
        """Test API health endpoint"""
        try:
            response = self.session.get(f"{BASE_URL}/health")
            if response.status_code == 200:
                data = response.json()
                self.log_result("Health Check", True, f"API is running: {data.get('message')}")
                return True
            else:
                self.log_result("Health Check", False, f"Health check failed with status {response.status_code}")
                return False
        except Exception as e:
            self.log_result("Health Check", False, f"Health check error: {str(e)}")
            return False
    
    def register_and_login_users(self):
        """Register and login test users"""
        for user_data in TEST_USERS:
            try:
                # Register user
                register_response = self.session.post(f"{BASE_URL}/auth/register", json=user_data)
                
                if register_response.status_code in [200, 201]:
                    # Login user
                    login_data = {
                        "email": user_data["email"],
                        "password": user_data["password"]
                    }
                    login_response = self.session.post(f"{BASE_URL}/auth/login", json=login_data)
                    
                    if login_response.status_code == 200:
                        login_result = login_response.json()
                        self.users[user_data["username"]] = {
                            "data": user_data,
                            "token": login_result.get("token"),
                            "user_id": login_result.get("user", {}).get("id"),
                            "headers": {"Authorization": f"Bearer {login_result.get('token')}"}
                        }
                        self.log_result(f"User Setup - {user_data['username']}", True, "User registered and logged in successfully")
                    else:
                        self.log_result(f"User Setup - {user_data['username']}", False, f"Login failed: {login_response.text}")
                else:
                    # Try to login if user already exists
                    login_data = {
                        "email": user_data["email"],
                        "password": user_data["password"]
                    }
                    login_response = self.session.post(f"{BASE_URL}/auth/login", json=login_data)
                    
                    if login_response.status_code == 200:
                        login_result = login_response.json()
                        self.users[user_data["username"]] = {
                            "data": user_data,
                            "token": login_result.get("token"),
                            "user_id": login_result.get("user", {}).get("id"),
                            "headers": {"Authorization": f"Bearer {login_result.get('token')}"}
                        }
                        self.log_result(f"User Setup - {user_data['username']}", True, "User logged in successfully (already existed)")
                    else:
                        self.log_result(f"User Setup - {user_data['username']}", False, f"Registration and login failed: {register_response.text}")
                        
            except Exception as e:
                self.log_result(f"User Setup - {user_data['username']}", False, f"User setup error: {str(e)}")
    
    def test_theme_authentication_required(self):
        """Test that theme endpoints require authentication"""
        print("\n🔐 Testing Authentication Requirements...")
        
        # Test GET /api/users/theme without authentication
        try:
            response = self.session.get(f"{BASE_URL}/users/theme")
            if response.status_code == 401:
                self.log_result("Theme Auth - GET Unauthenticated", True, "Correctly rejected unauthenticated GET request")
            else:
                self.log_result("Theme Auth - GET Unauthenticated", False, f"Expected 401, got {response.status_code}")
        except Exception as e:
            self.log_result("Theme Auth - GET Unauthenticated", False, f"Error testing unauthenticated GET: {str(e)}")
        
        # Test PUT /api/users/theme without authentication
        try:
            theme_data = {"themePreference": "darkClassic"}
            response = self.session.put(f"{BASE_URL}/users/theme", json=theme_data)
            if response.status_code == 401:
                self.log_result("Theme Auth - PUT Unauthenticated", True, "Correctly rejected unauthenticated PUT request")
            else:
                self.log_result("Theme Auth - PUT Unauthenticated", False, f"Expected 401, got {response.status_code}")
        except Exception as e:
            self.log_result("Theme Auth - PUT Unauthenticated", False, f"Error testing unauthenticated PUT: {str(e)}")
    
    def test_get_user_theme(self):
        """Test GET /api/users/theme endpoint"""
        print("\n📖 Testing GET Theme Endpoint...")
        
        if "theme_user_alice" not in self.users:
            self.log_result("GET Theme", False, "Test user not available")
            return
            
        user = self.users["theme_user_alice"]
        
        try:
            response = self.session.get(
                f"{BASE_URL}/users/theme",
                headers=user["headers"]
            )
            
            if response.status_code == 200:
                data = response.json()
                theme_preference = data.get("themePreference")
                
                if theme_preference:
                    if theme_preference == "darkClassic":
                        self.log_result("GET Theme - Default", True, f"Default theme correctly returned: {theme_preference}")
                    else:
                        self.log_result("GET Theme - Current", True, f"Current theme returned: {theme_preference}")
                else:
                    self.log_result("GET Theme", False, "No themePreference in response")
            else:
                self.log_result("GET Theme", False, f"GET theme failed with status {response.status_code}: {response.text}")
                
        except Exception as e:
            self.log_result("GET Theme", False, f"GET theme error: {str(e)}")
    
    def test_valid_theme_updates(self):
        """Test PUT /api/users/theme with all valid theme values"""
        print("\n🎨 Testing Valid Theme Updates...")
        
        if "theme_user_alice" not in self.users:
            self.log_result("Valid Theme Updates", False, "Test user not available")
            return
            
        user = self.users["theme_user_alice"]
        
        for theme in VALID_THEMES:
            try:
                theme_data = {"themePreference": theme}
                response = self.session.put(
                    f"{BASE_URL}/users/theme",
                    json=theme_data,
                    headers=user["headers"]
                )
                
                if response.status_code == 200:
                    data = response.json()
                    returned_theme = data.get("themePreference")
                    
                    if returned_theme == theme:
                        self.log_result(f"Valid Theme - {theme}", True, f"Theme {theme} updated successfully")
                    else:
                        self.log_result(f"Valid Theme - {theme}", False, f"Theme mismatch: sent {theme}, got {returned_theme}")
                else:
                    self.log_result(f"Valid Theme - {theme}", False, f"Theme update failed with status {response.status_code}: {response.text}")
                    
            except Exception as e:
                self.log_result(f"Valid Theme - {theme}", False, f"Theme update error: {str(e)}")
    
    def test_invalid_theme_updates(self):
        """Test PUT /api/users/theme with invalid theme values"""
        print("\n❌ Testing Invalid Theme Updates...")
        
        if "theme_user_bob" not in self.users:
            self.log_result("Invalid Theme Updates", False, "Test user not available")
            return
            
        user = self.users["theme_user_bob"]
        
        for invalid_theme in INVALID_THEMES:
            try:
                theme_data = {"themePreference": invalid_theme}
                response = self.session.put(
                    f"{BASE_URL}/users/theme",
                    json=theme_data,
                    headers=user["headers"]
                )
                
                if response.status_code == 400:
                    self.log_result(f"Invalid Theme - {invalid_theme}", True, f"Correctly rejected invalid theme: {invalid_theme}")
                else:
                    self.log_result(f"Invalid Theme - {invalid_theme}", False, f"Expected 400, got {response.status_code} for theme: {invalid_theme}")
                    
            except Exception as e:
                self.log_result(f"Invalid Theme - {invalid_theme}", False, f"Invalid theme test error: {str(e)}")
        
        # Test missing themePreference field
        try:
            response = self.session.put(
                f"{BASE_URL}/users/theme",
                json={},
                headers=user["headers"]
            )
            
            if response.status_code == 400:
                self.log_result("Invalid Theme - Missing Field", True, "Correctly rejected missing themePreference field")
            else:
                self.log_result("Invalid Theme - Missing Field", False, f"Expected 400, got {response.status_code} for missing field")
                
        except Exception as e:
            self.log_result("Invalid Theme - Missing Field", False, f"Missing field test error: {str(e)}")
    
    def test_profile_theme_integration(self):
        """Test PUT /api/users/profile with themePreference field"""
        print("\n👤 Testing Profile Theme Integration...")
        
        if "theme_user_carol" not in self.users:
            self.log_result("Profile Theme Integration", False, "Test user not available")
            return
            
        user = self.users["theme_user_carol"]
        
        # Test updating profile with theme preference
        try:
            profile_data = {
                "displayName": "Carol Updated Theme Tester",
                "bio": "Testing theme integration in profile",
                "themePreference": "lightPastel"
            }
            
            response = self.session.put(
                f"{BASE_URL}/users/profile",
                json=profile_data,
                headers=user["headers"]
            )
            
            if response.status_code == 200:
                data = response.json()
                user_profile = data.get("user", {})
                theme_preference = user_profile.get("themePreference")
                
                if theme_preference == "lightPastel":
                    self.log_result("Profile Theme Integration", True, f"Theme updated via profile: {theme_preference}")
                else:
                    self.log_result("Profile Theme Integration", False, f"Theme not updated in profile: {theme_preference}")
            else:
                self.log_result("Profile Theme Integration", False, f"Profile update failed with status {response.status_code}: {response.text}")
                
        except Exception as e:
            self.log_result("Profile Theme Integration", False, f"Profile theme integration error: {str(e)}")
    
    def test_theme_persistence(self):
        """Test that theme changes persist across requests"""
        print("\n💾 Testing Theme Persistence...")
        
        if "theme_user_alice" not in self.users:
            self.log_result("Theme Persistence", False, "Test user not available")
            return
            
        user = self.users["theme_user_alice"]
        test_theme = "darkNeon"
        
        # Set a specific theme
        try:
            theme_data = {"themePreference": test_theme}
            update_response = self.session.put(
                f"{BASE_URL}/users/theme",
                json=theme_data,
                headers=user["headers"]
            )
            
            if update_response.status_code != 200:
                self.log_result("Theme Persistence", False, f"Failed to set theme for persistence test: {update_response.text}")
                return
            
            # Wait a moment
            time.sleep(1)
            
            # Retrieve the theme to verify persistence
            get_response = self.session.get(
                f"{BASE_URL}/users/theme",
                headers=user["headers"]
            )
            
            if get_response.status_code == 200:
                data = get_response.json()
                retrieved_theme = data.get("themePreference")
                
                if retrieved_theme == test_theme:
                    self.log_result("Theme Persistence", True, f"Theme persisted correctly: {retrieved_theme}")
                else:
                    self.log_result("Theme Persistence", False, f"Theme not persisted: expected {test_theme}, got {retrieved_theme}")
            else:
                self.log_result("Theme Persistence", False, f"Failed to retrieve theme for persistence test: {get_response.text}")
                
        except Exception as e:
            self.log_result("Theme Persistence", False, f"Theme persistence test error: {str(e)}")
    
    def test_default_theme_for_new_users(self):
        """Test that new users get default theme (darkClassic)"""
        print("\n🆕 Testing Default Theme for New Users...")
        
        # Create a new user for this test
        new_user_data = {
            "username": f"new_theme_user_{int(time.time())}",
            "email": f"newuser{int(time.time())}@example.com",
            "password": "NewUserTest123",
            "displayName": "New Theme User"
        }
        
        try:
            # Register new user
            register_response = self.session.post(f"{BASE_URL}/auth/register", json=new_user_data)
            
            if register_response.status_code not in [200, 201]:
                self.log_result("Default Theme - New User", False, f"Failed to register new user: {register_response.text}")
                return
            
            # Login new user
            login_data = {
                "email": new_user_data["email"],
                "password": new_user_data["password"]
            }
            login_response = self.session.post(f"{BASE_URL}/auth/login", json=login_data)
            
            if login_response.status_code != 200:
                self.log_result("Default Theme - New User", False, f"Failed to login new user: {login_response.text}")
                return
            
            login_result = login_response.json()
            new_user_headers = {"Authorization": f"Bearer {login_result.get('token')}"}
            
            # Get theme for new user
            theme_response = self.session.get(
                f"{BASE_URL}/users/theme",
                headers=new_user_headers
            )
            
            if theme_response.status_code == 200:
                data = theme_response.json()
                theme_preference = data.get("themePreference")
                
                if theme_preference == "darkClassic":
                    self.log_result("Default Theme - New User", True, f"New user has correct default theme: {theme_preference}")
                else:
                    self.log_result("Default Theme - New User", False, f"New user has incorrect default theme: {theme_preference}")
            else:
                self.log_result("Default Theme - New User", False, f"Failed to get theme for new user: {theme_response.text}")
                
        except Exception as e:
            self.log_result("Default Theme - New User", False, f"Default theme test error: {str(e)}")
    
    def test_theme_in_profile_json(self):
        """Test that user profile JSON includes themePreference"""
        print("\n📋 Testing Theme in Profile JSON...")
        
        if "theme_user_alice" not in self.users:
            self.log_result("Theme in Profile JSON", False, "Test user not available")
            return
            
        user = self.users["theme_user_alice"]
        
        try:
            # Get user profile by username
            response = self.session.get(
                f"{BASE_URL}/users/profile/{user['data']['username']}",
                headers=user["headers"]
            )
            
            if response.status_code == 200:
                data = response.json()
                user_profile = data.get("user", {})
                theme_preference = user_profile.get("themePreference")
                
                if theme_preference:
                    if theme_preference in VALID_THEMES:
                        self.log_result("Theme in Profile JSON", True, f"Profile JSON includes valid theme: {theme_preference}")
                    else:
                        self.log_result("Theme in Profile JSON", False, f"Profile JSON has invalid theme: {theme_preference}")
                else:
                    self.log_result("Theme in Profile JSON", False, "Profile JSON missing themePreference field")
            else:
                self.log_result("Theme in Profile JSON", False, f"Failed to get user profile: {response.text}")
                
        except Exception as e:
            self.log_result("Theme in Profile JSON", False, f"Profile JSON test error: {str(e)}")
    
    def test_error_handling(self):
        """Test error handling scenarios"""
        print("\n🛡️ Testing Error Handling...")
        
        if "theme_user_alice" not in self.users:
            self.log_result("Error Handling", False, "Test user not available")
            return
            
        user = self.users["theme_user_alice"]
        
        # Test malformed JSON
        try:
            response = self.session.put(
                f"{BASE_URL}/users/theme",
                data="invalid json",
                headers={**user["headers"], "Content-Type": "application/json"}
            )
            
            if response.status_code == 400:
                self.log_result("Error Handling - Malformed JSON", True, "Correctly handled malformed JSON")
            else:
                self.log_result("Error Handling - Malformed JSON", False, f"Expected 400, got {response.status_code}")
                
        except Exception as e:
            self.log_result("Error Handling - Malformed JSON", False, f"Malformed JSON test error: {str(e)}")
        
        # Test invalid content type
        try:
            response = self.session.put(
                f"{BASE_URL}/users/theme",
                data="themePreference=darkClassic",
                headers={**user["headers"], "Content-Type": "application/x-www-form-urlencoded"}
            )
            
            # Should still work or return appropriate error
            if response.status_code in [200, 400]:
                self.log_result("Error Handling - Content Type", True, f"Handled content type appropriately: {response.status_code}")
            else:
                self.log_result("Error Handling - Content Type", False, f"Unexpected status for content type test: {response.status_code}")
                
        except Exception as e:
            self.log_result("Error Handling - Content Type", False, f"Content type test error: {str(e)}")
    
    def run_all_tests(self):
        """Run all theme backend tests"""
        print("🚀 Starting Comprehensive Theme System Backend Testing")
        print("=" * 70)
        
        # Health check
        if not self.test_health_check():
            print("❌ Server not responding, aborting tests")
            return
        
        # Setup users
        print("\n📋 Setting up test users...")
        self.register_and_login_users()
        
        if len(self.users) < 2:
            print("❌ Insufficient test users, aborting tests")
            return
        
        # Theme API Tests
        self.test_theme_authentication_required()
        self.test_get_user_theme()
        self.test_valid_theme_updates()
        self.test_invalid_theme_updates()
        self.test_profile_theme_integration()
        self.test_theme_persistence()
        self.test_default_theme_for_new_users()
        self.test_theme_in_profile_json()
        self.test_error_handling()
        
        # Summary
        self.print_summary()
    
    def print_summary(self):
        """Print test summary"""
        print("\n" + "=" * 70)
        print("📊 THEME SYSTEM TEST SUMMARY")
        print("=" * 70)
        
        total_tests = len(self.test_results)
        passed_tests = sum(1 for result in self.test_results if result["success"])
        failed_tests = total_tests - passed_tests
        
        print(f"Total Tests: {total_tests}")
        print(f"Passed: {passed_tests} ✅")
        print(f"Failed: {failed_tests} ❌")
        print(f"Success Rate: {(passed_tests/total_tests)*100:.1f}%")
        
        if failed_tests > 0:
            print("\n❌ FAILED TESTS:")
            for result in self.test_results:
                if not result["success"]:
                    print(f"  • {result['test']}: {result['message']}")
        
        print("\n🔍 KEY VALIDATIONS:")
        
        # Check theme validation
        theme_tests = [r for r in self.test_results if "Theme" in r["test"]]
        valid_theme_tests = [r for r in theme_tests if "Valid Theme" in r["test"] and r["success"]]
        invalid_theme_tests = [r for r in theme_tests if "Invalid Theme" in r["test"] and r["success"]]
        
        print(f"  ✅ Valid theme handling: {len(valid_theme_tests)}/{len(VALID_THEMES)} themes tested")
        print(f"  ✅ Invalid theme rejection: {len(invalid_theme_tests)} invalid cases handled")
        
        # Check authentication
        auth_tests = [r for r in self.test_results if "Auth" in r["test"] and r["success"]]
        if auth_tests:
            print(f"  ✅ Authentication requirements: {len(auth_tests)} tests passed")
        
        # Check persistence
        persistence_tests = [r for r in self.test_results if "Persistence" in r["test"] and r["success"]]
        if persistence_tests:
            print(f"  ✅ Theme persistence: {len(persistence_tests)} tests passed")
        
        # Check default theme
        default_tests = [r for r in self.test_results if "Default" in r["test"] and r["success"]]
        if default_tests:
            print(f"  ✅ Default theme handling: {len(default_tests)} tests passed")
        
        print("\n🎯 THEME SYSTEM BACKEND TESTING COMPLETE")

if __name__ == "__main__":
    tester = ThemeBackendTester()
    tester.run_all_tests()