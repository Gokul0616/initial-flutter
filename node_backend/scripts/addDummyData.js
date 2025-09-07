const mongoose = require('mongoose');
const { v4: uuidv4 } = require('uuid');
const bcrypt = require('bcryptjs');
require('dotenv').config();

// Import models
const User = require('../models/User');
const Story = require('../models/Story');
const Video = require('../models/Video');
const Message = require('../models/Message');

// Dummy video data from user
const dummyVideos = [
  {
    "description": "Big Buck Bunny tells the story of a giant rabbit with a heart bigger than himself. When one sunny day three rodents rudely harass him, something snaps... and the rabbit ain't no bunny anymore! In the typical cartoon tradition he prepares the nasty rodents a comical revenge.\n\nLicensed under the Creative Commons Attribution license\nhttp://www.bigbuckbunny.org",
    "sources": ["http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"],
    "subtitle": "By Blender Foundation",
    "thumb": "images/BigBuckBunny.jpg",
    "title": "Big Buck Bunny"
  },
  {
    "description": "The first Blender Open Movie from 2006",
    "sources": ["http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4"],
    "subtitle": "By Blender Foundation",
    "thumb": "images/ElephantsDream.jpg",
    "title": "Elephant Dream"
  },
  {
    "description": "HBO GO now works with Chromecast -- the easiest way to enjoy online video on your TV. For when you want to settle into your Iron Throne to watch the latest episodes. For $35.\nLearn how to use Chromecast with HBO GO and more at google.com/chromecast.",
    "sources": ["http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"],
    "subtitle": "By Google",
    "thumb": "images/ForBiggerBlazes.jpg",
    "title": "For Bigger Blazes"
  },
  {
    "description": "Introducing Chromecast. The easiest way to enjoy online video and music on your TV—for when Batman's escapes aren't quite big enough. For $35. Learn how to use Chromecast with Google Play Movies and more at google.com/chromecast.",
    "sources": ["http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4"],
    "subtitle": "By Google",
    "thumb": "images/ForBiggerEscapes.jpg",
    "title": "For Bigger Escape"
  },
  {
    "description": "Introducing Chromecast. The easiest way to enjoy online video and music on your TV. For $35.  Find out more at google.com/chromecast.",
    "sources": ["http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4"],
    "subtitle": "By Google",
    "thumb": "images/ForBiggerFun.jpg",
    "title": "For Bigger Fun"
  },
  {
    "description": "Introducing Chromecast. The easiest way to enjoy online video and music on your TV—for the times that call for bigger joyrides. For $35. Learn how to use Chromecast with YouTube and more at google.com/chromecast.",
    "sources": ["http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4"],
    "subtitle": "By Google",
    "thumb": "images/ForBiggerJoyrides.jpg",
    "title": "For Bigger Joyrides"
  },
  {
    "description": "Introducing Chromecast. The easiest way to enjoy online video and music on your TV—for when you want to make Buster's big meltdowns even bigger. For $35. Learn how to use Chromecast with Netflix and more at google.com/chromecast.",
    "sources": ["http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4"],
    "subtitle": "By Google",
    "thumb": "images/ForBiggerMeltdowns.jpg",
    "title": "For Bigger Meltdowns"
  },
  {
    "description": "Sintel is an independently produced short film, initiated by the Blender Foundation as a means to further improve and validate the free/open source 3D creation suite Blender. With initial funding provided by 1000s of donations via the internet community, it has again proven to be a viable development model for both open 3D technology as for independent animation film.\nThis 15 minute film has been realized in the studio of the Amsterdam Blender Institute, by an international team of artists and developers. In addition to that, several crucial technical and creative targets have been realized online, by developers and artists and teams all over the world.\nwww.sintel.org",
    "sources": ["http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4"],
    "subtitle": "By Blender Foundation",
    "thumb": "images/Sintel.jpg",
    "title": "Sintel"
  },
  {
    "description": "Smoking Tire takes the all-new Subaru Outback to the highest point we can find in hopes our customer-appreciation Balloon Launch will get some free T-shirts into the hands of our viewers.",
    "sources": ["http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4"],
    "subtitle": "By Garage419",
    "thumb": "images/SubaruOutbackOnStreetAndDirt.jpg",
    "title": "Subaru Outback On Street And Dirt"
  },
  {
    "description": "Tears of Steel was realized with crowd-funding by users of the open source 3D creation tool Blender. Target was to improve and test a complete open and free pipeline for visual effects in film - and to make a compelling sci-fi film in Amsterdam, the Netherlands.  The film itself, and all raw material used for making it, have been released under the Creatieve Commons 3.0 Attribution license. Visit the tearsofsteel.org website to find out more about this, or to purchase the 4-DVD box with a lot of extras.  (CC) Blender Foundation - http://www.tearsofsteel.org",
    "sources": ["http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4"],
    "subtitle": "By Blender Foundation",
    "thumb": "images/TearsOfSteel.jpg",
    "title": "Tears of Steel"
  },
  {
    "description": "The Smoking Tire heads out to Adams Motorsports Park in Riverside, CA to test the most requested car of 2010, the Volkswagen GTI. Will it beat the Mazdaspeed3's standard-setting lap time? Watch and see...",
    "sources": ["http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/VolkswagenGTIReview.mp4"],
    "subtitle": "By Garage419",
    "thumb": "images/VolkswagenGTIReview.jpg",
    "title": "Volkswagen GTI Review"
  },
  {
    "description": "The Smoking Tire is going on the 2010 Bullrun Live Rally in a 2011 Shelby GT500, and posting a video from the road every single day! The only place to watch them is by subscribing to The Smoking Tire or watching at BlackMagicShine.com",
    "sources": ["http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4"],
    "subtitle": "By Garage419",
    "thumb": "images/WeAreGoingOnBullrun.jpg",
    "title": "We Are Going On Bullrun"
  },
  {
    "description": "The Smoking Tire meets up with Chris and Jorge from CarsForAGrand.com to see just how far $1,000 can go when looking for a car.The Smoking Tire meets up with Chris and Jorge from CarsForAGrand.com to see just how far $1,000 can go when looking for a car.",
    "sources": ["http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4"],
    "subtitle": "By Garage419",
    "thumb": "images/WhatCarCanYouGetForAGrand.jpg",
    "title": "What care can you get for a grand?"
  }
];

// Dummy users data
const dummyUsers = [
  {
    username: "blender_official",
    email: "blender@example.com",
    displayName: "Blender Foundation",
    bio: "Open source 3D creation suite. Free forever. 🎨",
    profilePicture: "https://images.unsplash.com/photo-1633332755192-727a05c4013d?w=150&h=150&fit=crop&crop=face"
  },
  {
    username: "google_dev",
    email: "google@example.com",
    displayName: "Google Developers",
    bio: "Building the future with technology ⚡",
    profilePicture: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face"
  },
  {
    username: "garage419",
    email: "garage419@example.com",
    displayName: "Garage 419",
    bio: "Car reviews and automotive content 🚗",
    profilePicture: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face"
  },
  {
    username: "tech_creator",
    email: "tech@example.com",
    displayName: "Tech Creator",
    bio: "Creating awesome tech content 📱",
    profilePicture: "https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150&h=150&fit=crop&crop=face"
  },
  {
    username: "creative_studio",
    email: "creative@example.com",
    displayName: "Creative Studio",
    bio: "Digital art and creativity 🎭",
    profilePicture: "https://images.unsplash.com/photo-1494790108755-2616b332c7bd?w=150&h=150&fit=crop&crop=face"
  }
];

async function addDummyData() {
  try {
    // Connect to MongoDB
    console.log('Connecting to MongoDB...');
    // await mongoose.connect(process.env.MONGODB_URI, {
    //   useNewUrlParser: true,
    //   useUnifiedTopology: true,
    // });
    console.log('✅ Connected to MongoDB from dummy data');

    // Clear existing dummy data
    console.log('Clearing existing dummy data...');
    await User.deleteMany({ email: { $in: dummyUsers.map(u => u.email) } });
    await Story.deleteMany({});
    await Video.deleteMany({});

    // Create dummy users
    console.log('Creating dummy users...');
    const createdUsers = [];
    
    for (let i = 0; i < dummyUsers.length; i++) {
      const userData = dummyUsers[i];
      const hashedPassword = await bcrypt.hash('password123', 10);
      
      const user = new User({
        userId: uuidv4(),
        username: userData.username,
        email: userData.email,
        password: hashedPassword,
        displayName: userData.displayName,
        bio: userData.bio,
        profilePicture: userData.profilePicture,
        followersCount: Math.floor(Math.random() * 10000),
        followingCount: Math.floor(Math.random() * 1000),
        likesCount: Math.floor(Math.random() * 50000),
        videosCount: Math.floor(Math.random() * 100),
        isVerified: Math.random() > 0.5
      });
      
      await user.save();
      createdUsers.push(user);
      console.log(`✅ Created user: ${user.username}`);
    }

    // Create stories from videos
    console.log('Creating stories from videos...');
    for (let i = 0; i < dummyVideos.length; i++) {
      const videoData = dummyVideos[i];
      const randomUser = createdUsers[Math.floor(Math.random() * createdUsers.length)];
      
      const story = new Story({
        _id: uuidv4(),
        creator: randomUser.userId,
        content: 'video',
        mediaUrl: videoData.sources[0],
        thumbnailUrl: `https://images.unsplash.com/photo-${1500000000000 + i}?w=300&h=400&fit=crop`,
        text: videoData.title,
        textColor: '#FFFFFF',
        backgroundColor: '#000000',
        privacy: 'public',
        viewsCount: Math.floor(Math.random() * 1000),
        reactions: [
          {
            userId: createdUsers[Math.floor(Math.random() * createdUsers.length)].userId,
            emoji: '❤️'
          },
          {
            userId: createdUsers[Math.floor(Math.random() * createdUsers.length)].userId,
            emoji: '🔥'
          }
        ],
        hashtags: ['#video', '#content', '#tiktok']
      });
      
      await story.save();
      console.log(`✅ Created story: ${videoData.title}`);
    }

    // Create videos
    console.log('Creating videos...');
    for (let i = 0; i < dummyVideos.length; i++) {
      const videoData = dummyVideos[i];
      const randomUser = createdUsers[Math.floor(Math.random() * createdUsers.length)];
      
      const video = new Video({
        id: uuidv4(),
        user: randomUser._id,
        caption: videoData.description.substring(0, 200) + '...',
        videoUrl: videoData.sources[0],
        thumbnailUrl: `https://images.unsplash.com/photo-${1500000000000 + i}?w=300&h=400&fit=crop`,
        duration: Math.floor(Math.random() * 60) + 15, // 15-75 seconds
        likesCount: Math.floor(Math.random() * 10000),
        commentsCount: Math.floor(Math.random() * 500),
        sharesCount: Math.floor(Math.random() * 100),
        viewsCount: Math.floor(Math.random() * 50000),
        hashtags: ['#video', '#tiktok', '#content'],
        music: {
          title: 'Original Audio',
          artist: randomUser.displayName,
          url: videoData.sources[0]
        }
      });
      
      await video.save();
      console.log(`✅ Created video: ${videoData.title}`);
    }

    // Create sample messages between users
    console.log('Creating sample messages...');
    for (let i = 0; i < 20; i++) {
      const sender = createdUsers[Math.floor(Math.random() * createdUsers.length)];
      const recipient = createdUsers[Math.floor(Math.random() * createdUsers.length)];
      
      if (sender.userId !== recipient.userId) {
        const messageTypes = ['text', 'image', 'video', 'sticker'];
        const messageType = messageTypes[Math.floor(Math.random() * messageTypes.length)];
        
        const message = new Message({
          _id: uuidv4(),
          sender: sender.userId,
          recipient: recipient.userId,
          text: messageType === 'text' ? `Hey ${recipient.displayName}! How are you doing? 😊` : '',
          messageType: messageType,
          media: messageType !== 'text' ? {
            url: messageType === 'image' ? `https://images.unsplash.com/photo-${1500000000000 + i}?w=400&h=400&fit=crop` : 
                 messageType === 'video' ? dummyVideos[i % dummyVideos.length].sources[0] : 
                 'https://images.unsplash.com/photo-1500000000000?w=100&h=100&fit=crop',
            type: messageType,
            filename: `${messageType}_${i}.${messageType === 'image' ? 'jpg' : messageType === 'video' ? 'mp4' : 'png'}`,
            width: 400,
            height: 400
          } : undefined,
          reactions: Math.random() > 0.7 ? [
            {
              userId: recipient.userId,
              emoji: ['❤️', '😂', '👍', '🔥'][Math.floor(Math.random() * 4)]
            }
          ] : [],
          isRead: Math.random() > 0.3,
          status: 'delivered'
        });
        
        await message.save();
      }
    }

    console.log('✅ Dummy data added successfully!');
    console.log(`Created ${createdUsers.length} users`);
    console.log(`Created ${dummyVideos.length} stories`);
    console.log(`Created ${dummyVideos.length} videos`);
    console.log('Created 20 sample messages');
    
  } catch (error) {
    console.error('❌ Error adding dummy data:', error);
  // } finally {
    // await mongoose.disconnect();
    // console.log('Disconnected from MongoDB');
  }
}

module.exports = addDummyData;