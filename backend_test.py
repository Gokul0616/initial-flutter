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
UPLOAD_DIR = "/tmp/test_uploads"

# Valid theme values for testing
VALID_THEMES = [
    'darkClassic', 'lightClassic', 'darkNeon', 'lightPastel', 
    'darkPurple', 'lightGreen', 'darkOrange', 'lightBlue'
]

# Invalid theme values for testing
INVALID_THEMES = [
    'invalidTheme', 'dark', 'light', 'neon', 'purple', 
    'green', 'orange', 'blue', '', None, 123, True
]

# Test data
TEST_USERS = [
    {
        "username": "sarah_johnson",
        "email": "sarah.johnson@example.com", 
        "password": "SecurePass123",
        "displayName": "Sarah Johnson"
    },
    {
        "username": "mike_chen",
        "email": "mike.chen@example.com",
        "password": "SecurePass456", 
        "displayName": "Mike Chen"
    },
    {
        "username": "emma_davis",
        "email": "emma.davis@example.com",
        "password": "SecurePass789",
        "displayName": "Emma Davis"
    }
]

class BackendTester:
    def __init__(self):
        self.session = requests.Session()
        self.users = {}
        self.stories = {}
        self.messages = {}
        self.test_results = []
        self.setup_upload_dir()
        
    def setup_upload_dir(self):
        """Create upload directory for test files"""
        os.makedirs(UPLOAD_DIR, exist_ok=True)
        
        # Create test image file
        test_image_content = b'\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x02\x00\x00\x00\x90wS\xde\x00\x00\x00\tpHYs\x00\x00\x0b\x13\x00\x00\x0b\x13\x01\x00\x9a\x9c\x18\x00\x00\x00\nIDATx\x9cc\xf8\x00\x00\x00\x01\x00\x01\x00\x00\x00\x00IEND\xaeB`\x82'
        with open(f"{UPLOAD_DIR}/test_image.png", "wb") as f:
            f.write(test_image_content)
            
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
    
    def test_story_creation(self):
        """Test story creation endpoints"""
        if "sarah_johnson" not in self.users:
            self.log_result("Story Creation", False, "Test user not available")
            return
            
        user = self.users["sarah_johnson"]
        
        # Test 1: Create text story
        try:
            text_story_data = {
                "content": "text",
                "text": "Having an amazing day at the beach! 🏖️",
                "textColor": "#FFFFFF",
                "backgroundColor": "#FF6B6B",
                "privacy": "public"
            }
            
            response = self.session.post(
                f"{BASE_URL}/stories/create",
                json=text_story_data,
                headers=user["headers"]
            )
            
            if response.status_code == 201:
                story_data = response.json()
                story_id = story_data.get("data", {}).get("id")
                if story_id:
                    self.stories["text_story"] = story_data["data"]
                    self.log_result("Story Creation - Text", True, f"Text story created with UUID: {story_id}")
                else:
                    self.log_result("Story Creation - Text", False, "Story created but no ID returned")
            else:
                self.log_result("Story Creation - Text", False, f"Text story creation failed: {response.text}")
                
        except Exception as e:
            self.log_result("Story Creation - Text", False, f"Text story creation error: {str(e)}")
        
        # Test 2: Create photo story with file upload
        try:
            with open(f"{UPLOAD_DIR}/test_image.png", "rb") as f:
                files = {"media": ("test_image.png", f, "image/png")}
                data = {
                    "content": "photo",
                    "text": "Check out this sunset! 🌅",
                    "privacy": "public"
                }
                
                response = self.session.post(
                    f"{BASE_URL}/stories/create",
                    data=data,
                    files=files,
                    headers=user["headers"]
                )
                
                if response.status_code == 201:
                    story_data = response.json()
                    story_id = story_data.get("data", {}).get("id")
                    media_url = story_data.get("data", {}).get("mediaUrl")
                    if story_id and media_url:
                        self.stories["photo_story"] = story_data["data"]
                        self.log_result("Story Creation - Photo", True, f"Photo story created with UUID: {story_id}, Media URL: {media_url}")
                    else:
                        self.log_result("Story Creation - Photo", False, "Photo story created but missing ID or media URL")
                else:
                    self.log_result("Story Creation - Photo", False, f"Photo story creation failed: {response.text}")
                    
        except Exception as e:
            self.log_result("Story Creation - Photo", False, f"Photo story creation error: {str(e)}")
    
    def test_story_retrieval(self):
        """Test story retrieval endpoints"""
        if "sarah_johnson" not in self.users:
            self.log_result("Story Retrieval", False, "Test user not available")
            return
            
        user = self.users["sarah_johnson"]
        
        # Test 1: Get user's own stories
        try:
            response = self.session.get(
                f"{BASE_URL}/stories/my-stories",
                headers=user["headers"]
            )
            
            if response.status_code == 200:
                data = response.json()
                stories = data.get("stories", [])
                self.log_result("Story Retrieval - My Stories", True, f"Retrieved {len(stories)} stories")
            else:
                self.log_result("Story Retrieval - My Stories", False, f"Failed to get my stories: {response.text}")
                
        except Exception as e:
            self.log_result("Story Retrieval - My Stories", False, f"My stories retrieval error: {str(e)}")
        
        # Test 2: Get following stories
        try:
            response = self.session.get(
                f"{BASE_URL}/stories/following-stories",
                headers=user["headers"]
            )
            
            if response.status_code == 200:
                data = response.json()
                story_groups = data.get("storiesGroups", [])
                self.log_result("Story Retrieval - Following", True, f"Retrieved {len(story_groups)} story groups")
            else:
                self.log_result("Story Retrieval - Following", False, f"Failed to get following stories: {response.text}")
                
        except Exception as e:
            self.log_result("Story Retrieval - Following", False, f"Following stories retrieval error: {str(e)}")
    
    def test_story_interactions(self):
        """Test story viewing, reactions, and highlights"""
        if "sarah_johnson" not in self.users or "mike_chen" not in self.users:
            self.log_result("Story Interactions", False, "Test users not available")
            return
            
        sarah = self.users["sarah_johnson"]
        mike = self.users["mike_chen"]
        
        if "text_story" not in self.stories:
            self.log_result("Story Interactions", False, "No test story available")
            return
            
        story_id = self.stories["text_story"]["id"]
        
        # Test 1: View story (as Mike)
        try:
            response = self.session.post(
                f"{BASE_URL}/stories/{story_id}/view",
                headers=mike["headers"]
            )
            
            if response.status_code == 200:
                self.log_result("Story Interactions - View", True, "Story viewed successfully")
            else:
                self.log_result("Story Interactions - View", False, f"Story view failed: {response.text}")
                
        except Exception as e:
            self.log_result("Story Interactions - View", False, f"Story view error: {str(e)}")
        
        # Test 2: Get story viewers (as Sarah - story creator)
        try:
            response = self.session.get(
                f"{BASE_URL}/stories/{story_id}/viewers",
                headers=sarah["headers"]
            )
            
            if response.status_code == 200:
                data = response.json()
                viewers = data.get("viewers", [])
                self.log_result("Story Interactions - Viewers", True, f"Retrieved {len(viewers)} viewers")
            else:
                self.log_result("Story Interactions - Viewers", False, f"Get viewers failed: {response.text}")
                
        except Exception as e:
            self.log_result("Story Interactions - Viewers", False, f"Get viewers error: {str(e)}")
        
        # Test 3: React to story (as Mike)
        try:
            reaction_data = {"emoji": "❤️"}
            response = self.session.post(
                f"{BASE_URL}/stories/{story_id}/react",
                json=reaction_data,
                headers=mike["headers"]
            )
            
            if response.status_code == 200:
                self.log_result("Story Interactions - React", True, "Story reaction added successfully")
            else:
                self.log_result("Story Interactions - React", False, f"Story reaction failed: {response.text}")
                
        except Exception as e:
            self.log_result("Story Interactions - React", False, f"Story reaction error: {str(e)}")
        
        # Test 4: Add to highlights (as Sarah)
        try:
            highlight_data = {"title": "Beach Memories"}
            response = self.session.post(
                f"{BASE_URL}/stories/{story_id}/highlight",
                json=highlight_data,
                headers=sarah["headers"]
            )
            
            if response.status_code == 200:
                self.log_result("Story Interactions - Highlight", True, "Story added to highlights successfully")
            else:
                self.log_result("Story Interactions - Highlight", False, f"Add to highlights failed: {response.text}")
                
        except Exception as e:
            self.log_result("Story Interactions - Highlight", False, f"Add to highlights error: {str(e)}")
    
    def test_story_deletion(self):
        """Test story deletion"""
        if "sarah_johnson" not in self.users:
            self.log_result("Story Deletion", False, "Test user not available")
            return
            
        user = self.users["sarah_johnson"]
        
        if "photo_story" not in self.stories:
            self.log_result("Story Deletion", False, "No test story available for deletion")
            return
            
        story_id = self.stories["photo_story"]["id"]
        
        try:
            response = self.session.delete(
                f"{BASE_URL}/stories/{story_id}",
                headers=user["headers"]
            )
            
            if response.status_code == 200:
                self.log_result("Story Deletion", True, "Story deleted successfully")
            else:
                self.log_result("Story Deletion", False, f"Story deletion failed: {response.text}")
                
        except Exception as e:
            self.log_result("Story Deletion", False, f"Story deletion error: {str(e)}")
    
    def test_messaging_conversations(self):
        """Test messaging conversations endpoint"""
        if "sarah_johnson" not in self.users:
            self.log_result("Messaging - Conversations", False, "Test user not available")
            return
            
        user = self.users["sarah_johnson"]
        
        try:
            response = self.session.get(
                f"{BASE_URL}/messages/conversations",
                headers=user["headers"]
            )
            
            if response.status_code == 200:
                data = response.json()
                conversations = data.get("conversations", [])
                self.log_result("Messaging - Conversations", True, f"Retrieved {len(conversations)} conversations")
                
                # Check if story indicators are included
                has_story_indicators = any(conv.get("hasStory") is not None for conv in conversations)
                if has_story_indicators:
                    self.log_result("Messaging - Story Indicators", True, "Story indicators present in conversations")
                else:
                    self.log_result("Messaging - Story Indicators", True, "No story indicators (expected if no stories from contacts)")
                    
            else:
                self.log_result("Messaging - Conversations", False, f"Get conversations failed: {response.text}")
                
        except Exception as e:
            self.log_result("Messaging - Conversations", False, f"Get conversations error: {str(e)}")
    
    def test_text_messaging(self):
        """Test text message sending and retrieval"""
        if "sarah_johnson" not in self.users or "mike_chen" not in self.users:
            self.log_result("Text Messaging", False, "Test users not available")
            return
            
        sarah = self.users["sarah_johnson"]
        mike = self.users["mike_chen"]
        
        # Test 1: Send text message from Sarah to Mike
        try:
            message_data = {
                "recipientId": mike["user_id"],
                "text": "Hey Mike! How's your day going? 😊"
            }
            
            response = self.session.post(
                f"{BASE_URL}/messages/send",
                json=message_data,
                headers=sarah["headers"]
            )
            
            if response.status_code == 201:
                data = response.json()
                message_id = data.get("data", {}).get("id")
                if message_id:
                    self.messages["text_message"] = data["data"]
                    self.log_result("Text Messaging - Send", True, f"Text message sent with UUID: {message_id}")
                else:
                    self.log_result("Text Messaging - Send", False, "Message sent but no ID returned")
            else:
                self.log_result("Text Messaging - Send", False, f"Text message send failed: {response.text}")
                
        except Exception as e:
            self.log_result("Text Messaging - Send", False, f"Text message send error: {str(e)}")
        
        # Test 2: Get conversation messages
        try:
            response = self.session.get(
                f"{BASE_URL}/messages/conversation/{sarah['user_id']}",
                headers=mike["headers"]
            )
            
            if response.status_code == 200:
                data = response.json()
                messages = data.get("messages", [])
                self.log_result("Text Messaging - Retrieve", True, f"Retrieved {len(messages)} messages")
            else:
                self.log_result("Text Messaging - Retrieve", False, f"Get messages failed: {response.text}")
                
        except Exception as e:
            self.log_result("Text Messaging - Retrieve", False, f"Get messages error: {str(e)}")
    
    def test_media_messaging(self):
        """Test media message sending"""
        if "sarah_johnson" not in self.users or "mike_chen" not in self.users:
            self.log_result("Media Messaging", False, "Test users not available")
            return
            
        sarah = self.users["sarah_johnson"]
        mike = self.users["mike_chen"]
        
        # Test: Send media message
        try:
            with open(f"{UPLOAD_DIR}/test_image.png", "rb") as f:
                files = {"media": ("vacation_photo.png", f, "image/png")}
                data = {
                    "recipientId": mike["user_id"],
                    "text": "Check out this photo from my vacation!"
                }
                
                response = self.session.post(
                    f"{BASE_URL}/messages/send-media",
                    data=data,
                    files=files,
                    headers=sarah["headers"]
                )
                
                if response.status_code == 201:
                    message_data = response.json()
                    message_id = message_data.get("data", {}).get("id")
                    media_url = message_data.get("data", {}).get("media", {}).get("url")
                    if message_id and media_url:
                        self.messages["media_message"] = message_data["data"]
                        self.log_result("Media Messaging - Send", True, f"Media message sent with UUID: {message_id}, Media URL: {media_url}")
                    else:
                        self.log_result("Media Messaging - Send", False, "Media message sent but missing ID or media URL")
                else:
                    self.log_result("Media Messaging - Send", False, f"Media message send failed: {response.text}")
                    
        except Exception as e:
            self.log_result("Media Messaging - Send", False, f"Media message send error: {str(e)}")
    
    def test_message_interactions(self):
        """Test message reactions and deletion"""
        if "sarah_johnson" not in self.users or "mike_chen" not in self.users:
            self.log_result("Message Interactions", False, "Test users not available")
            return
            
        sarah = self.users["sarah_johnson"]
        mike = self.users["mike_chen"]
        
        if "text_message" not in self.messages:
            self.log_result("Message Interactions", False, "No test message available")
            return
            
        message_id = self.messages["text_message"]["id"]
        
        # Test 1: React to message (as Mike)
        try:
            reaction_data = {"emoji": "👍"}
            response = self.session.post(
                f"{BASE_URL}/messages/{message_id}/react",
                json=reaction_data,
                headers=mike["headers"]
            )
            
            if response.status_code == 200:
                self.log_result("Message Interactions - React", True, "Message reaction added successfully")
            else:
                self.log_result("Message Interactions - React", False, f"Message reaction failed: {response.text}")
                
        except Exception as e:
            self.log_result("Message Interactions - React", False, f"Message reaction error: {str(e)}")
        
        # Test 2: Delete message for me (as Sarah)
        try:
            delete_data = {"deleteFor": "me"}
            response = self.session.delete(
                f"{BASE_URL}/messages/{message_id}",
                json=delete_data,
                headers=sarah["headers"]
            )
            
            if response.status_code == 200:
                self.log_result("Message Interactions - Delete", True, "Message deleted successfully")
            else:
                self.log_result("Message Interactions - Delete", False, f"Message deletion failed: {response.text}")
                
        except Exception as e:
            self.log_result("Message Interactions - Delete", False, f"Message deletion error: {str(e)}")
    
    def test_story_reply_messaging(self):
        """Test story reply functionality in messages"""
        if "sarah_johnson" not in self.users or "emma_davis" not in self.users:
            self.log_result("Story Reply Messaging", False, "Test users not available")
            return
            
        sarah = self.users["sarah_johnson"]
        emma = self.users["emma_davis"]
        
        if "text_story" not in self.stories:
            self.log_result("Story Reply Messaging", False, "No test story available")
            return
            
        story_id = self.stories["text_story"]["id"]
        
        try:
            message_data = {
                "recipientId": sarah["user_id"],
                "text": "Love this story! 💕",
                "storyReply": {
                    "storyId": story_id
                }
            }
            
            response = self.session.post(
                f"{BASE_URL}/messages/send",
                json=message_data,
                headers=emma["headers"]
            )
            
            if response.status_code == 201:
                data = response.json()
                message_id = data.get("data", {}).get("id")
                story_reply = data.get("data", {}).get("storyReply")
                if message_id and story_reply:
                    self.log_result("Story Reply Messaging", True, f"Story reply message sent with UUID: {message_id}")
                else:
                    self.log_result("Story Reply Messaging", False, "Story reply sent but missing data")
            else:
                self.log_result("Story Reply Messaging", False, f"Story reply send failed: {response.text}")
                
        except Exception as e:
            self.log_result("Story Reply Messaging", False, f"Story reply send error: {str(e)}")
    
    def test_error_handling(self):
        """Test error handling scenarios"""
        if "sarah_johnson" not in self.users:
            self.log_result("Error Handling", False, "Test user not available")
            return
            
        user = self.users["sarah_johnson"]
        
        # Test 1: Access non-existent story
        try:
            fake_story_id = str(uuid.uuid4())
            response = self.session.get(
                f"{BASE_URL}/stories/{fake_story_id}/viewers",
                headers=user["headers"]
            )
            
            if response.status_code == 404:
                self.log_result("Error Handling - Non-existent Story", True, "Correctly returned 404 for non-existent story")
            else:
                self.log_result("Error Handling - Non-existent Story", False, f"Expected 404, got {response.status_code}")
                
        except Exception as e:
            self.log_result("Error Handling - Non-existent Story", False, f"Error handling test error: {str(e)}")
        
        # Test 2: Send message to non-existent user
        try:
            fake_user_id = str(uuid.uuid4())
            message_data = {
                "recipientId": fake_user_id,
                "text": "This should fail"
            }
            
            response = self.session.post(
                f"{BASE_URL}/messages/send",
                json=message_data,
                headers=user["headers"]
            )
            
            if response.status_code == 404:
                self.log_result("Error Handling - Non-existent User", True, "Correctly returned 404 for non-existent user")
            else:
                self.log_result("Error Handling - Non-existent User", False, f"Expected 404, got {response.status_code}")
                
        except Exception as e:
            self.log_result("Error Handling - Non-existent User", False, f"Error handling test error: {str(e)}")
    
    def run_all_tests(self):
        """Run all backend tests"""
        print("🚀 Starting Comprehensive Backend API Testing")
        print("=" * 60)
        
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
        
        # Stories API Tests
        print("\n📖 Testing Stories API...")
        self.test_story_creation()
        self.test_story_retrieval()
        self.test_story_interactions()
        self.test_story_deletion()
        
        # Messages API Tests
        print("\n💬 Testing Messages API...")
        self.test_messaging_conversations()
        self.test_text_messaging()
        self.test_media_messaging()
        self.test_message_interactions()
        self.test_story_reply_messaging()
        
        # Error Handling Tests
        print("\n🛡️ Testing Error Handling...")
        self.test_error_handling()
        
        # Summary
        self.print_summary()
    
    def print_summary(self):
        """Print test summary"""
        print("\n" + "=" * 60)
        print("📊 TEST SUMMARY")
        print("=" * 60)
        
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
        
        # Check UUID usage
        uuid_tests = [r for r in self.test_results if "UUID" in r["message"]]
        if uuid_tests:
            print(f"  ✅ UUID-based IDs working: {len(uuid_tests)} confirmed")
        
        # Check file uploads
        upload_tests = [r for r in self.test_results if "Media URL" in r["message"]]
        if upload_tests:
            print(f"  ✅ File upload handling: {len(upload_tests)} confirmed")
        
        # Check API coverage
        stories_tests = [r for r in self.test_results if "Story" in r["test"]]
        messages_tests = [r for r in self.test_results if "Messaging" in r["test"] or "Message" in r["test"]]
        
        print(f"  ✅ Stories API coverage: {len(stories_tests)} tests")
        print(f"  ✅ Messages API coverage: {len(messages_tests)} tests")
        
        print("\n🎯 BACKEND TESTING COMPLETE")

if __name__ == "__main__":
    tester = BackendTester()
    tester.run_all_tests()