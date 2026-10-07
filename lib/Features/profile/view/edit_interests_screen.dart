// features/profile/view/edit_interests_screen.dart

import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Features/profile/view/desktop/desktop_edit_subpage_shell.dart';
import 'package:everqpidapp/Features/profile/view/desktop/desktop_form_controls.dart';
import 'package:everqpidapp/Features/profile/view_model/update_profile_view_model.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/utils/p_colors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class EditInterestsScreen extends StatefulWidget {
  const EditInterestsScreen({super.key});

  @override
  State<EditInterestsScreen> createState() => _EditInterestsScreenState();
}

class _EditInterestsScreenState extends State<EditInterestsScreen> {
  List<String> _selectedInterests = [];

  // final List<InterestItem> _interests = [
  //   InterestItem(emoji: '🐕', name: 'Dogs'),
  //   InterestItem(emoji: '🎵', name: 'Music'),
  //   InterestItem(emoji: '🎬', name: 'Movies'),
  //   InterestItem(emoji: '🛍️', name: 'Shopping'),
  //   InterestItem(emoji: '📷', name: 'Photography'),
  //   InterestItem(emoji: '✈️', name: 'Travel'),
  //   InterestItem(emoji: '🍳', name: 'Cooking'),
  //   InterestItem(emoji: '📚', name: 'Reading'),
  //   InterestItem(emoji: '🎮', name: 'Gaming'),
  //   InterestItem(emoji: '⚽', name: 'Sports'),
  //   InterestItem(emoji: '🎨', name: 'Art'),
  //   InterestItem(emoji: '💃', name: 'Dancing'),
  //   InterestItem(emoji: '🏋️', name: 'Fitness'),
  //   InterestItem(emoji: '🧘', name: 'Yoga'),
  //   InterestItem(emoji: '🌿', name: 'Nature'),
  //   InterestItem(emoji: '📝', name: 'Blogging'),
  // ];
//  final List<InterestItem> _interests = [
//   InterestItem(emoji: '🎬', name: 'Animated movies'),
//   InterestItem(emoji: '🕵️‍♂️', name: 'Crime shows'),
//   InterestItem(emoji: '🎭', name: 'Drama shows'),
//   InterestItem(emoji: '🧙‍♂️', name: 'Fantasy movies'),
//   InterestItem(emoji: '🎥', name: 'Documentaries'),
//   InterestItem(emoji: '🎞️', name: 'Indie films'),
//   InterestItem(emoji: '📺', name: 'Reality TV'),
//   InterestItem(emoji: '💘', name: 'Rom-coms'),
//   InterestItem(emoji: '🏟️', name: 'Sports shows'),
//   InterestItem(emoji: '😱', name: 'Thriller films'),
//   InterestItem(emoji: '🇰🇷', name: 'K-drama shows'),
//   InterestItem(emoji: '👻', name: 'Horror Movies'),
//   InterestItem(emoji: '🎬', name: 'Bollywood'),
//   InterestItem(emoji: '🎥', name: 'Movies'),
//   InterestItem(emoji: '👽', name: 'Sci-Fi'),
//   InterestItem(emoji: '🍥', name: 'Anime'),
//   InterestItem(emoji: '😂', name: 'Comedy'),

//   // Social causes
//   InterestItem(emoji: '✊', name: 'Activism'),
//   InterestItem(emoji: '🧠', name: 'Mental Health Awareness'),
//   InterestItem(emoji: '🗳️', name: 'Voter Rights'),
//   InterestItem(emoji: '🌍', name: 'Climate Change'),
//   InterestItem(emoji: '🏳️‍🌈', name: 'LGBTQIA+ Rights'),
//   InterestItem(emoji: '♀️', name: 'Feminism'),
//   InterestItem(emoji: '✊🏿', name: 'Black Lives Matter'),
//   InterestItem(emoji: '🤝', name: 'Inclusivity'),
//   InterestItem(emoji: '⚖️', name: 'Human Rights'),
//   InterestItem(emoji: '🏘️', name: 'Social Development'),
//   InterestItem(emoji: '🙋‍♂️', name: 'Volunteering'),
//   InterestItem(emoji: '🌱', name: 'Environmentalism'),
//   InterestItem(emoji: '🕊️', name: 'World Peace'),
//   InterestItem(emoji: '🏳️‍🌈', name: 'Pride'),
//   InterestItem(emoji: '🚀', name: 'Youth Empowerment'),
//   InterestItem(emoji: '⚖️', name: 'Equality'),
//   InterestItem(emoji: '🏛️', name: 'Politics'),
//   InterestItem(emoji: '♿', name: 'Disability Rights'),

//   // Wellness
//   InterestItem(emoji: '💖', name: 'Self Love'),
//   InterestItem(emoji: '🧪', name: 'Trying New Things'),
//   InterestItem(emoji: '🔮', name: 'Tarot'),
//   InterestItem(emoji: '💆‍♀️', name: 'Spa'),
//   InterestItem(emoji: '🛀', name: 'Self Care'),
//   InterestItem(emoji: '📈', name: 'Self Development'),
//   InterestItem(emoji: '🧘', name: 'Meditation'),
//   InterestItem(emoji: '🧴', name: 'Skincare'),
//   InterestItem(emoji: '💄', name: 'Makeup'),
//   InterestItem(emoji: '♈', name: 'Astrology'),
//   InterestItem(emoji: '🧘‍♂️', name: 'Mindfulness'),
//   InterestItem(emoji: '🔥', name: 'Sauna'),
//   InterestItem(emoji: '🏃‍♂️', name: 'Active Lifestyle'),
//   InterestItem(emoji: '🧘‍♀️', name: 'Yoga'),

//   // Creative
//   InterestItem(emoji: '📸', name: 'Photography'),
//   InterestItem(emoji: '✍️', name: 'Writing'),
//   InterestItem(emoji: '📚', name: 'Literature'),
//   InterestItem(emoji: '🎨', name: 'Painting'),
//   InterestItem(emoji: '🖌️', name: 'Drawing'),
//   InterestItem(emoji: '🎭', name: 'Art'),
//   InterestItem(emoji: '📝', name: 'Blogging'),
//   InterestItem(emoji: '🎤', name: 'Singing'),
//   InterestItem(emoji: '🎼', name: 'Musical Writing'),
//   InterestItem(emoji: '🎹', name: 'Musical Instrument'),
//   InterestItem(emoji: '🕺', name: 'Dancing'),

//   // Food
//   InterestItem(emoji: '🍜', name: 'Ramen'),
//   InterestItem(emoji: '🍣', name: 'Sushi'),
//   InterestItem(emoji: '🍛', name: 'Biryani'),
//   InterestItem(emoji: '🍔', name: 'Street Food'),
//   InterestItem(emoji: '🍨', name: 'Ice Cream'),
//   InterestItem(emoji: '☕', name: 'Coffee'),
//   InterestItem(emoji: '🍵', name: 'Tea'),
//   InterestItem(emoji: '🍱', name: 'Korean Food'),
//   InterestItem(emoji: '🥗', name: 'Plant-based'),
//   InterestItem(emoji: '🍽️', name: 'Foodie'),

//   // Tech & Gaming
//   InterestItem(emoji: '🎮', name: 'Gaming'),
//   InterestItem(emoji: '🕹️', name: 'PlayStation'),
//   InterestItem(emoji: '🎮', name: 'Xbox'),
//   InterestItem(emoji: '👾', name: 'Online Games'),
//   InterestItem(emoji: '🧠', name: 'Trivia'),
//   InterestItem(emoji: '🎲', name: 'Ludo'),

//   // Travel & Outdoor
//   InterestItem(emoji: '🏕️', name: 'Camping'),
//   InterestItem(emoji: '🥾', name: 'Hiking'),
//   InterestItem(emoji: '🏖️', name: 'Beach'),
//   InterestItem(emoji: '🌄', name: 'Mountains'),
//   InterestItem(emoji: '✈️', name: 'Travel'),
//   InterestItem(emoji: '🌿', name: 'Nature'),
//   InterestItem(emoji: '🚗', name: 'Road Trips'),

//   // Fitness & Sports
//   InterestItem(emoji: '🏋️‍♂️', name: 'Gym'),
//   InterestItem(emoji: '🏃', name: 'Running'),
//   InterestItem(emoji: '⚽', name: 'Football'),
//   InterestItem(emoji: '🏀', name: 'Basketball'),
//   InterestItem(emoji: '🏸', name: 'Badminton'),
//   InterestItem(emoji: '🏊‍♂️', name: 'Swimming'),
//   InterestItem(emoji: '🚴‍♂️', name: 'Cycling'),
// ];

  final List<String> _interests = [
    "Poetry",
    "Sneakers",
    "Freelancing",
    "Photography",
    "Choir",
    "Cosplay",
    "Content Creation",
    "Vintage fashion",
    "Investing",
    "Singing",
    "Language Exchange",
    "Writing",
    "Literature",
    "NFTs",
    "Tattoos",
    "Painting",
    "Upcycling",
    "Entrepreneurship",
    "Acapella",
    "Musical Instrument",
    "Musical Writing",
    "Dancing",
    "Exchange Program",
    "Art",
    "Real Estate",
    "Drawing",
    "Blogging",
    "Fashion",
    "DIY",
    "90s Kid",
    "Comic-con",
    "Harry Potter",
    "NBA",
    "MLB",
    "Dungeons & Dragons",
    "Manga",
    "Marvel",
    "Disney",
    "Maggi",
    "Biryani",
    "Sushi",
    "Foodie",
    "Food tours",
    "Mocktails",
    "Sweet treats",
    "Brunch",
    "Açaí",
    "Street Food",
    "Plant-based",
    "Boba tea",
    "Cocktails",
    "Ice Cream",
    "Coffee",
    "Pho",
    "Wine",
    "Ramen",
    "Korean Food",
    "BBQ",
    "Craft Beer",
    "Tea",
    "Ludo",
    "PlayStation",
    "E-Sports",
    "Fortnite",
    "Xbox",
    "League of Legends",
    "Nintendo",
    "Among Us",
    "Atari",
    "Roblox",
    "Festivals",
    "Stand up Comedy",
    "Escape Rooms",
    "Bars",
    "Thrifting",
    "Museums",
    "Paragliding",
    "Sailing",
    "Hiking",
    "Mountains",
    "Backpacking",
    "Rock Climbing",
    "Fishing",
    "Camping",
    "Outdoors",
    "Picnicking",
    "Instagram",
    "X",
    "SoundCloud",
    "Pinterest",
    "Spotify",
    "Social Media",
    "Vlogging",
    "YouTube",
    "Virtual Reality",
    "Memes",
    "Metaverse",
    "Podcasts",
    "TikTok",
    "Twitch",
    "Netflix",
    "Freeletics",
    "Cricket",
    "Ice Hockey",
    "Sports Shooting",
    "Athletics",
    "Sports",
    "Walking",
    "Beach sports",
    "Fitness classes",
    "Skating",
    "Rugby",
    "Boxing",
    "Badminton",
    "Pilates",
    "Cheerleading",
    "Pole Dancing",
    "Car Racing",
    "Motor Sports",
    "Jogging",
    "Football",
    "Tennis",
    "Skateboarding",
    "Gymnastics",
    "Hockey",
    "Basketball",
    "Running",
    "Gym",
    "Weightlifting",
    "Wrestling",
    "Marathon",
    "Martial Arts",
    "Volleyball",
    "Padel",
    "Equestrian",
    "Soccer",
    "Baseball",
    "Archery",
    "Crossfit",
    "Climbing",
    "Cycling",
    "Swimming",
    "Table Tennis",
    "Working out",
    "Reading",
    "Binge-Watching TV shows",
    "Home Workout",
    "Trivia",
    "Cooking",
    "Online Games",
    "Online Shopping",
    "Animated movies",
    "Crime shows",
    "Drama shows",
    "Fantasy movies",
    "Documentaries",
    "Indie films",
    "Reality TV",
    "Rom-coms",
    "Sports shows",
    "Thriller films",
    "K-drama shows",
    "Horror Movies",
    "Bollywood",
    "Movies",
    "Sci-Fi",
    "Anime",
    "Comedy",
    "Activism",
    "Mental Health Awareness",
    "Voter Rights",
    "Climate Change",
    "LGBTQIA+ Rights",
    "Feminism",
    "Black Lives Matter",
    "Inclusivity",
    "Human Rights",
    "Social Development",
    "Volunteering",
    "Environmentalism",
    "World Peace",
    "Pride",
    "Youth Empowerment",
    "Equality",
    "Politics",
    "Disability Rights",
    "Self Love",
    "Trying New Things",
    "Tarot",
    "Spa",
    "Self Care",
    "Self Development",
    "Meditation",
    "Skincare",
    "Makeup",
    "Astrology",
    "Mindfulness",
    "Sauna",
    "Active Lifestyle",
    "Yoga",
    "Raves",
    "Drive-in Cinema",
    "Musical theater",
    "Cafe hopping",
    "Aquarium",
    "Clubbing",
    "Exhibition",
    "Shopping",
    "Cars",
    "Pub Quiz",
    "Happy hour",
    "Karaoke",
    "House Parties",
    "Theater",
    "Shisha",
    "Rollerskating",
    "Live Music",
    "Bar Hopping",
    "Bowling",
    "Motorcycles",
    "Parties",
    "Nightlife",
    "Art galleries",
    "Film Festival",
    "Pubs",
    "Concerts",
    "Town Festivities",
    "Bhangra",
    "K-Pop",
    "Gospel music",
    "Music bands",
    "Rock music",
    "Soul music",
    "Pop music",
    "Punk rock",
    "Rap music",
    "Folk music",
    "Latin music",
    "Alternative music",
    "Techno",
    "Jazz",
    "House music",
    "EDM",
    "R&B",
    "Indie music",
    "Opera",
    "Heavy Metal",
    "Funk music",
    "Reggaeton",
    "Country Music",
    "Hip Hop",
    "J-Pop",
    "Electronic Music",
    "Grime",
    "90s Britpop",
    "Trap Music",
    "Music",
    "Road Trips",
    "Rowing",
    "Diving",
    "Jetskiing",
    "Walking tours",
    "Nature",
    "Hot Springs",
    "Walking My Dog",
    "Skiing",
    "Canoeing",
    "Snowboarding",
    "Couchsurfing",
    "Free Diving",
    "Travel",
    "Paddle Boarding",
    "Surfing",
    "Beach Bars",
  ];

  @override
  void initState() {
    super.initState();

    // Load current values from ViewModel
    final viewModel = context.read<ProfileViewModel>();
    _selectedInterests = List<String>.from(viewModel.interests);
  }

  void _saveAndGoBack() {
    final viewModel = context.read<ProfileViewModel>();
    viewModel.setInterests(_selectedInterests);
    Fluttertoast.showToast(msg: 'Interests updated successfully');
    Navigator.pop(context, true);
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        _selectedInterests.add(interest);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProfileEditResponsive(
      mobile: (_) => _buildMobile(),
      desktop: (_) => _buildDesktop(),
    );
  }

  Widget _buildDesktop() {
    final selected = _selectedInterests.toSet();
    return DesktopSubpageBody(
      header: const DesktopSubpageHeader(
        title: 'Hobbies & Interests',
        subtitle: 'Tell us what makes you, you.',
      ),
      tip: DesktopTipCard(
        title: 'Your picks',
        tips: [
          '${_selectedInterests.length} interest${_selectedInterests.length == 1 ? '' : 's'} selected',
          'Pick a mix that feels like you',
          'You can update these anytime',
        ],
      ),
      saveBar: DesktopSaveBar(
        onSave: _saveAndGoBack,
        enabled: _selectedInterests.isNotEmpty,
      ),
      form: DesktopFormCard(
        title: 'What are your Interests?',
        icon: Icons.auto_awesome_outlined,
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final interest in _interests)
              _DesktopInterestChip(
                emoji: _getEmoji(interest),
                name: interest,
                selected: selected.contains(interest),
                onTap: () => _toggleInterest(interest),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobile() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Back',
          style: getTextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What are your\nInterests?',
                    style: getTextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tell us what makes you, you.',
                    style: getTextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _interests.map((interest) {
                      final isSelected = _selectedInterests.contains(interest);
                      return _buildInterestChip(
                        emoji: _getEmoji(interest),
                        name: interest,
                        isSelected: isSelected,
                        onTap: () => _toggleInterest(interest),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _selectedInterests.isNotEmpty ? _saveAndGoBack : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedInterests.isNotEmpty
                        ? PColors.primaryColor
                        : Colors.grey[300],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Save',
                    style: getTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _selectedInterests.isNotEmpty
                          ? Colors.white
                          : Colors.grey[500],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getEmoji(String interest) {
    final map = {
      // Creative & Arts
      "Poetry": "📜",
      "Photography": "📸",
      "Painting": "🎨",
      "Drawing": "✏️",
      "Art": "🖼️",
      "Writing": "✍️",
      "Literature": "📖",
      "Blogging": "📝",
      "Content Creation": "🎙️",
      "Vlogging": "🎥",
      "DIY": "🔧",
      "Upcycling": "♻️",
      "Cosplay": "🦸",
      "Tattoos": "🖋️",

      // Fashion & Style
      "Sneakers": "👟",
      "Vintage fashion": "👗",
      "Fashion": "👠",
      "Thrifting": "🛍️",
      "Skincare": "🧴",
      "Makeup": "💄",

      // Music
      "Music": "🎵",
      "Singing": "🎤",
      "Choir": "🎶",
      "Acapella": "🎼",
      "Musical Instrument": "🎸",
      "Musical Writing": "🎹",
      "Dancing": "💃",
      "K-Pop": "🇰🇷",
      "Gospel music": "✝️",
      "Music bands": "🎸",
      "Rock music": "🤘",
      "Soul music": "🎷",
      "Pop music": "🎤",
      "Punk rock": "🎸",
      "Rap music": "🎤",
      "Folk music": "🪕",
      "Latin music": "💃",
      "Alternative music": "🎵",
      "Techno": "🎛️",
      "Jazz": "🎺",
      "House music": "🏠",
      "EDM": "🎧",
      "R&B": "🎵",
      "Indie music": "🎸",
      "Opera": "🎭",
      "Heavy Metal": "🤘",
      "Funk music": "🕺",
      "Reggaeton": "🎶",
      "Country Music": "🤠",
      "Hip Hop": "🎤",
      "J-Pop": "🎌",
      "Electronic Music": "🎛️",
      "Grime": "🎤",
      "90s Britpop": "🎸",
      "Trap Music": "🎵",
      "Bhangra": "🥁",

      // Food & Drink
      "Maggi": "🍜",
      "Biryani": "🍛",
      "Sushi": "🍣",
      "Foodie": "🍽️",
      "Food tours": "🗺️",
      "Mocktails": "🥤",
      "Sweet treats": "🍬",
      "Brunch": "🥞",
      "Açaí": "🫐",
      "Street Food": "🌮",
      "Plant-based": "🥗",
      "Boba tea": "🧋",
      "Cocktails": "🍹",
      "Ice Cream": "🍨",
      "Coffee": "☕",
      "Pho": "🍜",
      "Wine": "🍷",
      "Ramen": "🍜",
      "Korean Food": "🥢",
      "BBQ": "🍖",
      "Craft Beer": "🍺",
      "Tea": "🍵",

      // Gaming
      "Ludo": "🎲",
      "PlayStation": "🎮",
      "E-Sports": "🏆",
      "Fortnite": "🎯",
      "Xbox": "🎮",
      "League of Legends": "⚔️",
      "Nintendo": "🕹️",
      "Among Us": "🚀",
      "Atari": "🕹️",
      "Roblox": "🧱",
      "Online Games": "💻",
      "Dungeons & Dragons": "🐉",

      // Entertainment
      "Festivals": "🎪",
      "Stand up Comedy": "🎤",
      "Escape Rooms": "🔐",
      "Bars": "🍸",
      "Museums": "🏛️",
      "Movies": "🎬",
      "Anime": "🍥",
      "Binge-Watching TV shows": "📺",
      "Trivia": "🧠",
      "Animated movies": "🎠",
      "Crime shows": "🔍",
      "Drama shows": "🎭",
      "Fantasy movies": "🧙",
      "Documentaries": "🎞️",
      "Indie films": "🎬",
      "Reality TV": "📺",
      "Rom-coms": "💕",
      "Sports shows": "📺",
      "Thriller films": "😱",
      "K-drama shows": "🇰🇷",
      "Horror Movies": "👻",
      "Bollywood": "🕺",
      "Sci-Fi": "🚀",
      "Comedy": "😂",
      "Manga": "📚",
      "Marvel": "🦸",
      "Disney": "🏰",
      "Harry Potter": "⚡",
      "Comic-con": "🦸",
      "90s Kid": "📼",

      // Outdoors & Adventure
      "Paragliding": "🪂",
      "Sailing": "⛵",
      "Hiking": "🥾",
      "Mountains": "⛰️",
      "Backpacking": "🎒",
      "Rock Climbing": "🧗",
      "Fishing": "🎣",
      "Camping": "🏕️",
      "Outdoors": "🌲",
      "Picnicking": "🧺",
      "Road Trips": "🚗",
      "Rowing": "🚣",
      "Diving": "🤿",
      "Jetskiing": "🚤",
      "Walking tours": "🗺️",
      "Nature": "🌿",
      "Hot Springs": "♨️",
      "Skiing": "⛷️",
      "Canoeing": "🛶",
      "Snowboarding": "🏂",
      "Couchsurfing": "🛋️",
      "Free Diving": "🤿",
      "Travel": "✈️",
      "Paddle Boarding": "🏄",
      "Surfing": "🏄",
      "Beach Bars": "🍹",
      "Walking My Dog": "🐕",

      // Social Media & Tech
      "Instagram": "📷",
      "X": "𝕏",
      "SoundCloud": "🎧",
      "Pinterest": "📌",
      "Spotify": "🎵",
      "Social Media": "📱",
      "YouTube": "▶️",
      "Virtual Reality": "🥽",
      "Memes": "😂",
      "Metaverse": "🌐",
      "Podcasts": "🎙️",
      "TikTok": "🎵",
      "Twitch": "🎮",
      "Netflix": "🎬",
      "NFTs": "🖼️",

      // Sports & Fitness
      "Freeletics": "🏃",
      "Cricket": "🏏",
      "Ice Hockey": "🏒",
      "Sports Shooting": "🎯",
      "Athletics": "🏅",
      "Sports": "⚽",
      "Walking": "🚶",
      "Beach sports": "🏖️",
      "Fitness classes": "🤸",
      "Skating": "⛸️",
      "Rugby": "🏉",
      "Boxing": "🥊",
      "Badminton": "🏸",
      "Pilates": "🧘",
      "Cheerleading": "📣",
      "Pole Dancing": "💫",
      "Car Racing": "🏎️",
      "Motor Sports": "🏍️",
      "Jogging": "🏃",
      "Football": "🏈",
      "Tennis": "🎾",
      "Skateboarding": "🛹",
      "Gymnastics": "🤸",
      "Hockey": "🏒",
      "Basketball": "🏀",
      "Running": "🏃",
      "Gym": "🏋️",
      "Weightlifting": "🏋️",
      "Wrestling": "🤼",
      "Marathon": "🏅",
      "Martial Arts": "🥋",
      "Volleyball": "🏐",
      "Padel": "🎾",
      "Equestrian": "🐎",
      "Soccer": "⚽",
      "Baseball": "⚾",
      "Archery": "🏹",
      "Crossfit": "💪",
      "Climbing": "🧗",
      "Cycling": "🚴",
      "Swimming": "🏊",
      "Table Tennis": "🏓",
      "Working out": "💪",
      "Home Workout": "🏠",
      "NBA": "🏀",
      "MLB": "⚾",

      // Wellness & Self
      "Self Love": "💝",
      "Trying New Things": "🌟",
      "Tarot": "🔮",
      "Spa": "💆",
      "Self Care": "🛁",
      "Self Development": "📈",
      "Meditation": "🧘",
      "Astrology": "⭐",
      "Mindfulness": "🌸",
      "Sauna": "🧖",
      "Active Lifestyle": "🌟",
      "Yoga": "🧘",

      // Social & Nightlife
      "Raves": "🎉",
      "Drive-in Cinema": "🚗",
      "Musical theater": "🎭",
      "Cafe hopping": "☕",
      "Aquarium": "🐠",
      "Clubbing": "🕺",
      "Exhibition": "🖼️",
      "Shopping": "🛍️",
      "Cars": "🚗",
      "Pub Quiz": "🧠",
      "Happy hour": "🍻",
      "Karaoke": "🎤",
      "House Parties": "🏠",
      "Theater": "🎭",
      "Shisha": "💨",
      "Rollerskating": "🛼",
      "Live Music": "🎸",
      "Bar Hopping": "🍻",
      "Bowling": "🎳",
      "Motorcycles": "🏍️",
      "Parties": "🎉",
      "Nightlife": "🌙",
      "Art galleries": "🖼️",
      "Film Festival": "🎬",
      "Pubs": "🍺",
      "Concerts": "🎵",
      "Town Festivities": "🎊",

      // Finance & Business
      "Freelancing": "💼",
      "Investing": "📈",
      "Entrepreneurship": "🚀",
      "Real Estate": "🏠",

      // Social Causes
      "Activism": "✊",
      "Mental Health Awareness": "🧠",
      "Voter Rights": "🗳️",
      "Climate Change": "🌍",
      "LGBTQIA+ Rights": "🏳️‍🌈",
      "Feminism": "♀️",
      "Black Lives Matter": "✊",
      "Inclusivity": "🤝",
      "Human Rights": "⚖️",
      "Social Development": "🌱",
      "Volunteering": "🤲",
      "Environmentalism": "♻️",
      "World Peace": "☮️",
      "Pride": "🌈",
      "Youth Empowerment": "💪",
      "Equality": "⚖️",
      "Politics": "🗳️",
      "Disability Rights": "♿",

      // Exchange & Community
      "Language Exchange": "🌐",
      "Exchange Program": "🎓",

      // Hobbies
      "Cooking": "🍳",
      "Reading": "📚",
      "Online Shopping": "🛒",
    };
    return map[interest] ?? "✨";
  }

  Widget _buildInterestChip({
    required String emoji,
    required String name,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? PColors.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? PColors.primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              name,
              style: getTextStyle(
                fontSize: 15,
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopInterestChip extends StatefulWidget {
  const _DesktopInterestChip({
    required this.emoji,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_DesktopInterestChip> createState() => _DesktopInterestChipState();
}

class _DesktopInterestChipState extends State<_DesktopInterestChip> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: selected
              ? WelcomeTheme.violet.withValues(alpha: 0.28)
              : _hover
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? WelcomeTheme.violet.withValues(alpha: 0.55)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.emoji, style: const TextStyle(fontSize: 15)),
                  const SizedBox(width: 7),
                  Text(
                    widget.name,
                    style: getTextStyle(
                      fontSize: 13,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class InterestItem {
  final String emoji;
  final String name;

  InterestItem({required this.emoji, required this.name});
}
