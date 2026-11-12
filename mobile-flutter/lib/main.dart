import 'package:flutter/material.dart';

void main() {
  runApp(const YoUnMeApp());
}

class YoUnMeApp extends StatelessWidget {
  const YoUnMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YoUnMe Dating App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF080A10),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF2D55),
          secondary: Color(0xFF00E5FF),
          surface: Color(0xFF0F121D),
          tertiary: Color(0xFFFFD700),
        ),
      ),
      home: const MainShellScreen(),
    );
  }
}

class CandidateProfile {
  final String id;
  final String name;
  final int age;
  final String city;
  final double distanceKm;
  final String bio;
  final String imagePath;
  final bool isVerified;
  final int vibeScore;
  final List<String> interests;

  const CandidateProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.city,
    required this.distanceKm,
    required this.bio,
    required this.imagePath,
    required this.isVerified,
    required this.vibeScore,
    required this.interests,
  });
}

final List<CandidateProfile> demoProfiles = [
  const CandidateProfile(
    id: 'ananya',
    name: 'Ananya',
    age: 24,
    city: 'Mumbai (Bandra West)',
    distanceKm: 1.2,
    bio:
        'UI/UX designer & matcha enthusiast 🍵 Sucker for dry wit, vintage typography, and quiet corners in Bandra cafes.',
    imagePath: 'assets/images/ananya.jpg',
    isVerified: true,
    vibeScore: 96,
    interests: ['Specialty Coffee ☕', 'Indie Vinyl 🎵', 'Modern Art 🎨'],
  ),
  const CandidateProfile(
    id: 'kavya',
    name: 'Kavya',
    age: 23,
    city: 'Bengaluru (Indiranagar)',
    distanceKm: 2.4,
    bio:
        'Architect sketching streetscapes and hoarding fountain pens ✏️ Passionate about brutalist buildings and filter coffee.',
    imagePath: 'assets/images/kavya.jpg',
    isVerified: true,
    vibeScore: 94,
    interests: ['Architecture 🏛️', 'Filter Coffee ☕', 'Sketching ✏️'],
  ),
  const CandidateProfile(
    id: 'zoya',
    name: 'Zoya',
    age: 25,
    city: 'Hyderabad (Jubilee Hills)',
    distanceKm: 4.8,
    bio:
        'Analog photographer & biryani philosopher 📸 Take me to your favorite hidden terrace or vintage flea market.',
    imagePath: 'assets/images/zoya.jpg',
    isVerified: true,
    vibeScore: 91,
    interests: ['Photography 📷', 'Biryani 🍛', 'Film Noir 🎬'],
  ),
  const CandidateProfile(
    id: 'arjun',
    name: 'Arjun',
    age: 30,
    city: 'Bengaluru (Koramangala)',
    distanceKm: 3.7,
    bio:
        'Trail runner & machine learning researcher 🏃 Weekends are reserved for misty ridge hikes and sunrise summits.',
    imagePath: 'assets/images/arjun.jpg',
    isVerified: true,
    vibeScore: 87,
    interests: ['Trail Running 🏃', 'Machine Learning 🤖', 'Hiking 🥾'],
  ),
  const CandidateProfile(
    id: 'riya',
    name: 'Riya',
    age: 26,
    city: 'Mumbai (Colaba)',
    distanceKm: 5.1,
    bio:
        'Fashion curator & cinema buff 🎬 Strolling Colaba art deco lanes, tasting artisanal gelato, and debating Wes Anderson.',
    imagePath: 'assets/images/riya.jpg',
    isVerified: true,
    vibeScore: 90,
    interests: ['Salsa 💃', 'Film Aesthetics 🎥', 'Gelato 🍨'],
  ),
  const CandidateProfile(
    id: 'kabir',
    name: 'Kabir',
    age: 26,
    city: 'Mumbai (Khar West)',
    distanceKm: 2.1,
    bio:
        'Sound designer & vinyl collector 🎧 Always hunting for obscure Japanese jazz, late-night bakeries, and breezy coastal drives.',
    imagePath: 'assets/images/kabir.jpg',
    isVerified: true,
    vibeScore: 95,
    interests: ['Specialty Coffee ☕', 'Indie Vinyl 🎵', 'Live Jazz 🎷'],
  ),
  const CandidateProfile(
    id: 'meera',
    name: 'Meera',
    age: 27,
    city: 'Delhi (Hauz Khas)',
    distanceKm: 6.8,
    bio:
        'Indie bookstore lover & chai purist 📚 Terrible at speed chess but I’ll happily challenge you to a round.',
    imagePath: 'assets/images/meera.jpg',
    isVerified: true,
    vibeScore: 93,
    interests: ['Books 📚', 'Masala Chai ☕', 'Chess ♟️'],
  ),
  const CandidateProfile(
    id: 'tanya',
    name: 'Tanya',
    age: 22,
    city: 'Goa (Panaji)',
    distanceKm: 3.5,
    bio:
        'Marine biology student & scuba addict 🤿 Ocean breezes, bioluminescence swims, and reggae rhythms under coconut groves.',
    imagePath: 'assets/images/tanya.jpg',
    isVerified: true,
    vibeScore: 89,
    interests: ['Beaches 🏖️', 'Scuba Diving 🤿', 'Reggae 🎶'],
  ),
  const CandidateProfile(
    id: 'nikhil',
    name: 'Nikhil',
    age: 31,
    city: 'Pune (Koregaon Park)',
    distanceKm: 7.2,
    bio:
        'Craft brewer & sourdough experimenter 🍞 Let’s talk fermentation science, indie post-rock bands, and 90s sci-fi.',
    imagePath: 'assets/images/nikhil.jpg',
    isVerified: true,
    vibeScore: 85,
    interests: ['Sourdough 🥖', 'Craft Beer 🍺', 'Post-Rock 🎸'],
  ),
  const CandidateProfile(
    id: 'sneha',
    name: 'Sneha',
    age: 24,
    city: 'Chennai (Besant Nagar)',
    distanceKm: 4.1,
    bio:
        'Carnatic-fusion violinist 🎻 Live concert lover, rooftop sunset watcher, and passionate defender of spicy ramen.',
    imagePath: 'assets/images/sneha.jpg',
    isVerified: true,
    vibeScore: 97,
    interests: ['Violin 🎻', 'Ramen 🍜', 'Indie Fusion 🎶'],
  ),
  const CandidateProfile(
    id: 'tara',
    name: 'Tara',
    age: 25,
    city: 'Jaipur (C-Scheme)',
    distanceKm: 8.3,
    bio:
        'Creative director & clay ceramicist 🏺 Plant guardian to 24 succulents. Come make ceramic mugs and talk aesthetic cinema.',
    imagePath: 'assets/images/tara.jpg',
    isVerified: true,
    vibeScore: 89,
    interests: ['Pottery 🏺', 'Succulents 🪴', 'Art Direction 📐'],
  ),
  const CandidateProfile(
    id: 'ishaan',
    name: 'Ishaan',
    age: 28,
    city: 'Gurugram (Cyber City)',
    distanceKm: 9.6,
    bio:
        'Venture builder & astronomy enthusiast 🔭 Down for 2 AM deep philosophical debates over single-origin pourovers.',
    imagePath: 'assets/images/ishaan.jpg',
    isVerified: true,
    vibeScore: 93,
    interests: ['Astrophysics 🌌', 'Pourover ☕', 'Startups 🚀'],
  ),
  const CandidateProfile(
    id: 'aisha',
    name: 'Aisha',
    age: 23,
    city: 'Bhopal (Arera Colony)',
    distanceKm: 11,
    bio:
        'Wildlife photojournalist 🐆 Either tracking big cats across forest reserves or sitting in a hammock editing raw shots.',
    imagePath: 'assets/images/aisha.jpg',
    isVerified: true,
    vibeScore: 88,
    interests: ['Wildlife 🐾', 'Expeditions 🚙', 'Forest Treks 🌲'],
  ),
  const CandidateProfile(
    id: 'dev',
    name: 'Dev',
    age: 29,
    city: 'Ahmedabad (Navrangpura)',
    distanceKm: 6.2,
    bio:
        'Sustainable architect & boulderer 🧗 Designing solar passive buildings by daylight and tackling V6 overhangs.',
    imagePath: 'assets/images/dev.jpg',
    isVerified: true,
    vibeScore: 92,
    interests: ['Bouldering 🧗', 'Eco Architecture 🌿', 'Espresso ☕'],
  ),
  const CandidateProfile(
    id: 'priya',
    name: 'Priya',
    age: 25,
    city: 'Kolkata (Park Street)',
    distanceKm: 8.7,
    bio:
        'Culinary food historian & pastry experimenter 🍰 Creating saffron-infused treats and collecting heirloom family recipes.',
    imagePath: 'assets/images/priya.jpg',
    isVerified: true,
    vibeScore: 94,
    interests: ['Baking 🥐', 'Culinary History 🍲', 'Jazz 🎷'],
  ),
  const CandidateProfile(
    id: 'rohit',
    name: 'Rohit',
    age: 27,
    city: 'Mumbai (Juhu)',
    distanceKm: 4.5,
    bio:
        'Landscape architect by day, acoustic rock guitarist by evening 🎸 Chasing coastal sea spray and talking late-night design.',
    imagePath: 'assets/images/rohit.jpg',
    isVerified: true,
    vibeScore: 91,
    interests: ['Guitar 🎸', 'Architecture 🏛️', 'Sunset Runs 🌅'],
  ),
  const CandidateProfile(
    id: 'aditya',
    name: 'Aditya',
    age: 28,
    city: 'Kochi (Fort Kochi)',
    distanceKm: 5.9,
    bio:
        'Indie game developer & retro synthesizer geek 🕹️ Making cozy pixel games, brewing aeropress, and cycling sea walls.',
    imagePath: 'assets/images/aditya.jpg',
    isVerified: true,
    vibeScore: 95,
    interests: ['Game Dev 🎮', 'Retro Synths 🎹', 'Cycling 🚴'],
  ),
  const CandidateProfile(
    id: 'diya',
    name: 'Diya',
    age: 24,
    city: 'Mumbai (Pali Hill)',
    distanceKm: 1.8,
    bio:
        'Editorial fashion stylist & vintage bazaar hunter 👗 Finding hidden textile gems, sipping cold brew, and golden hours.',
    imagePath: 'assets/images/diya.jpg',
    isVerified: true,
    vibeScore: 97,
    interests: ['Vintage Styling 👗', 'Cold Brew 🧊', 'Fashion Editorial 📸'],
  ),
  const CandidateProfile(
    id: 'vivaan',
    name: 'Vivaan',
    age: 26,
    city: 'Bengaluru (HSR Layout)',
    distanceKm: 3.1,
    bio:
        'Fintech co-founder & road cyclist 🚴 Early 100k breakfast rides, podcast debates, and hand-pulled espresso shots.',
    imagePath: 'assets/images/vivaan.jpg',
    isVerified: true,
    vibeScore: 93,
    interests: ['Road Cycling 🚴', 'Espresso ☕', 'Fintech 💡'],
  ),
  const CandidateProfile(
    id: 'natasha',
    name: 'Natasha',
    age: 25,
    city: 'Delhi (Shahpur Jat)',
    distanceKm: 6.4,
    bio:
        'Mural artist & digital illustrator 🎨 Splashing colors on urban walls, illustrating indie graphic novels, and sipping chai.',
    imagePath: 'assets/images/natasha.jpg',
    isVerified: true,
    vibeScore: 90,
    interests: ['Mural Art 🎨', 'Graphic Novels 📚', 'Tea Stalls ☕'],
  ),
  const CandidateProfile(
    id: 'sameer',
    name: 'Sameer',
    age: 27,
    city: 'Pune (Viman Nagar)',
    distanceKm: 5.6,
    bio:
        'Fingerstyle acoustic guitarist & songwriter 🎸 Composing chill melodies, sipping green tea, and jamming under starry skies.',
    imagePath: 'assets/images/sameer.jpg',
    isVerified: true,
    vibeScore: 92,
    interests: ['Acoustic Guitar 🎸', 'Songwriting 🎼', 'Camping ⛺'],
  ),
  const CandidateProfile(
    id: 'rhea',
    name: 'Rhea',
    age: 23,
    city: 'Goa (Anjuna)',
    distanceKm: 4.2,
    bio:
        'Coral reef conservationist & free diver 🤿 Protecting marine life, sunset bonfires on secluded coves, and honest talks.',
    imagePath: 'assets/images/rhea.jpg',
    isVerified: true,
    vibeScore: 94,
    interests: ['Free Diving 🤿', 'Ocean Conservation 🌊', 'Bonfires 🔥'],
  ),
  const CandidateProfile(
    id: 'kunal',
    name: 'Kunal',
    age: 28,
    city: 'Hyderabad (Gachibowli)',
    distanceKm: 7,
    bio:
        'Hardware robotics engineer & drone pilot 🛸 Building autonomous tech by day, star trail astrophotography by night.',
    imagePath: 'assets/images/kunal.jpg',
    isVerified: true,
    vibeScore: 86,
    interests: ['Drones 🛸', 'Robotics 🤖', 'Astrophotography 🌌'],
  ),
  const CandidateProfile(
    id: 'alisha',
    name: 'Alisha',
    age: 26,
    city: 'Mumbai (Santacruz West)',
    distanceKm: 2.9,
    bio:
        'French-trained pastry chef & chocolatier 🍫 Come taste warm almond croissants, flaky tartlets, and single-origin bonbons.',
    imagePath: 'assets/images/alisha.jpg',
    isVerified: true,
    vibeScore: 96,
    interests: ['Pastry 🥐', 'Chocolaterie 🍫', 'Fine Dining 🍷'],
  ),
  const CandidateProfile(
    id: 'karan',
    name: 'Karan',
    age: 27,
    city: 'Chandigarh (Sector 18)',
    distanceKm: 9.3,
    bio:
        'Triathlon competitor & sports nutritionist 🏊‍♂️ Running half marathons, blending green superfood smoothies, and high energy.',
    imagePath: 'assets/images/karan.jpg',
    isVerified: true,
    vibeScore: 88,
    interests: ['Triathlon 🏊‍♂️', 'Nutrition 🥗', 'Trail Biking 🚵‍♂️'],
  ),
  const CandidateProfile(
    id: 'pooja',
    name: 'Pooja',
    age: 24,
    city: 'Kolkata (Salt Lake)',
    distanceKm: 6.9,
    bio:
        'Slow-living advocate & terracotta ceramicist 🪴 Hand-crafting earthy tableware, collecting first-edition books, and fine tea.',
    imagePath: 'assets/images/pooja.jpg',
    isVerified: true,
    vibeScore: 92,
    interests: ['Ceramics 🏺', 'Darjeeling Tea ☕', 'Slow Living 🌿'],
  ),
  const CandidateProfile(
    id: 'siddharth',
    name: 'Siddharth',
    age: 29,
    city: 'Ahmedabad (Ellisbridge)',
    distanceKm: 5.7,
    bio:
        'Heritage conservation architect 🏛️ Documenting 500-year-old stepwells and havelis. Loves black ink pens and classical sitar.',
    imagePath: 'assets/images/siddharth.jpg',
    isVerified: true,
    vibeScore: 94,
    interests: ['Heritage 🏛️', 'Ink Drawing 🖋️', 'Classical Music 🎶'],
  ),
  const CandidateProfile(
    id: 'neha',
    name: 'Neha',
    age: 25,
    city: 'Chennai (Adyar)',
    distanceKm: 4.9,
    bio:
        'Contemporary dancer & yoga teacher 🧘 Exploring expressive human movement, sound bath therapy, and dawn over the bay.',
    imagePath: 'assets/images/neha.jpg',
    isVerified: true,
    vibeScore: 95,
    interests: ['Contemporary Dance 💃', 'Yoga 🧘', 'Sound Healing 🔔'],
  ),
  const CandidateProfile(
    id: 'rahul',
    name: 'Rahul',
    age: 26,
    city: 'Kochi (Mattancherry)',
    distanceKm: 6.3,
    bio:
        'Estate micro-lot coffee roaster ☕ Obsessed with light roasts, fruity pour-over notes, analog photography, and monsoons.',
    imagePath: 'assets/images/rahul.jpg',
    isVerified: true,
    vibeScore: 89,
    interests: ['Specialty Coffee ☕', 'Roasting ♨️', 'Monsoon Walks 🌧️'],
  ),
  const CandidateProfile(
    id: 'simran',
    name: 'Simran',
    age: 27,
    city: 'Shimla (Mall Road)',
    distanceKm: 12.5,
    bio:
        'Mountain essayist & fiction author ✍️ Pine forest wanderer with a mechanical typewriter. Coffee, wool sweaters, and woodsmoke.',
    imagePath: 'assets/images/simran.jpg',
    isVerified: true,
    vibeScore: 94,
    interests: ['Writing ✍️', 'Pine Forest Hikes 🌲', 'Typewriters ⌨️'],
  ),
  const CandidateProfile(
    id: 'varun',
    name: 'Varun',
    age: 28,
    city: 'Manali (Old Manali)',
    distanceKm: 13.2,
    bio:
        'High-altitude alpine trek leader 🏔️ Navigating high passes, glacier safety, and warming up with campfire stories and guitar.',
    imagePath: 'assets/images/varun.jpg',
    isVerified: true,
    vibeScore: 91,
    interests: ['Mountaineering 🧗‍♂️', 'Alpine Hikes 🏔️', 'Campfires 🔥'],
  ),
  const CandidateProfile(
    id: 'maya',
    name: 'Maya',
    age: 24,
    city: 'Mumbai (Versova)',
    distanceKm: 3.8,
    bio:
        'Independent documentary filmmaker 🎥 Unearthing real stories of indie street musicians, quiet artisans, and forgotten streets.',
    imagePath: 'assets/images/maya.jpg',
    isVerified: true,
    vibeScore: 96,
    interests: ['Documentary 🎥', 'Soundscapes 🎙️', 'Indie Cinema 🍿'],
  ),
  const CandidateProfile(
    id: 'aman',
    name: 'Aman',
    age: 26,
    city: 'Bengaluru (Indiranagar)',
    distanceKm: 2.8,
    bio:
        'Quantitative trader & blitz chess player ♟️ Mathematical models during the week, underground lo-fi vinyl gigs on weekends.',
    imagePath: 'assets/images/aman.jpg',
    isVerified: true,
    vibeScore: 92,
    interests: ['Chess ♟️', 'Quantitative Math 📊', 'Lo-Fi Beats 🎧'],
  ),
  const CandidateProfile(
    id: 'shruti',
    name: 'Shruti',
    age: 25,
    city: 'Jaipur (Malviya Nagar)',
    distanceKm: 7.6,
    bio:
        'Botanist & wild perfumer 🌸 Distilling rare forest blossoms, foraging botanicals, and handcrafting niche scents.',
    imagePath: 'assets/images/shruti.jpg',
    isVerified: true,
    vibeScore: 93,
    interests: ['Botany 🌿', 'Natural Perfumery 🌸', 'Herb Gardens 🪴'],
  ),
  const CandidateProfile(
    id: 'aryan',
    name: 'Aryan',
    age: 27,
    city: 'Pune (Baner)',
    distanceKm: 6,
    bio:
        'Clean-tech innovator & landscape photographer 🌅 Building solar grids, chasing golden hour timelapses, and open highway trips.',
    imagePath: 'assets/images/aryan.jpg',
    isVerified: true,
    vibeScore: 95,
    interests: ['Solar Energy ☀️', 'Landscape Photography 📷', 'Road Trips 🚗'],
  ),
];

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const DiscoveryDeckScreen(),
      const ConnectStackScreen(),
      const Center(
          child: Text("💬 Chat & Contact Guard Filter",
              style: TextStyle(fontSize: 18))),
      const Center(
          child: Text("📞 LiveKit Cloud SFU WebRTC Calls",
              style: TextStyle(fontSize: 18))),
      const Center(
          child: Text("🪙 Profile, Blue Tick & Double-Entry Ledger",
              style: TextStyle(fontSize: 18))),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF080A10).withValues(alpha: 0.95),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFFFF2D55), Color(0xFF9B51E0)]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.local_fire_department,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              "YoUnMe",
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  letterSpacing: -0.5),
            ),
          ],
        ),
        actions: [
          // Ruby / Coin balance
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
            ),
            child: const Row(
              children: [
                Icon(Icons.monetization_on, color: Colors.amber, size: 15),
                SizedBox(width: 4),
                Text("250",
                    style: TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Daily Streak Badge (beside notification icon)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFF7A39).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: const Color(0xFFFF7A39).withValues(alpha: 0.45)),
            ),
            child: const Row(
              children: [
                Icon(Icons.local_fire_department,
                    color: Color(0xFFFF7A39), size: 16),
                SizedBox(width: 3),
                Text("4",
                    style: TextStyle(
                        color: Color(0xFFFF7A39),
                        fontWeight: FontWeight.w800,
                        fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Notifications Icon
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.15)),
                ),
                child: const Icon(Icons.notifications_none_rounded,
                    color: Colors.white, size: 18),
              ),
              Positioned(
                top: 7,
                right: 7,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF2D55),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        backgroundColor: const Color(0xFF0F121D),
        indicatorColor: const Color(0xFFFF2D55).withValues(alpha: 0.25),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore),
              label: 'Discovery'),
          NavigationDestination(
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite),
              label: 'Connect'),
          NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline),
              selectedIcon: Icon(Icons.chat_bubble),
              label: 'Chat'),
          NavigationDestination(
              icon: Icon(Icons.phone_outlined),
              selectedIcon: Icon(Icons.phone),
              label: 'Calls'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile'),
        ],
      ),
    );
  }
}

class DiscoveryDeckScreen extends StatefulWidget {
  const DiscoveryDeckScreen({super.key});

  @override
  State<DiscoveryDeckScreen> createState() => _DiscoveryDeckScreenState();
}

class _DiscoveryDeckScreenState extends State<DiscoveryDeckScreen> {
  late List<CandidateProfile> _activeProfiles;
  final List<CandidateProfile> _outgoingLikes = [];
  int _likeCount = 0;

  @override
  void initState() {
    super.initState();
    _activeProfiles = List.from(demoProfiles);
  }

  void _resetDeck() {
    setState(() {
      _activeProfiles = List.from(demoProfiles);
      _likeCount = 0;
    });
  }

  void _nextProfile(String action) {
    if (_activeProfiles.isEmpty) return;
    final profile = _activeProfiles.first;

    // Strict 1-2 matches per 10 likes (positions 4 and 9)
    bool isMatch = false;
    if (action == 'Liked' || action == 'Sparked') {
      _likeCount++;
      final pos = ((_likeCount - 1) % 10) + 1;
      isMatch = (pos == 4 || pos == 9);
      _outgoingLikes.add(profile);
    }

    // Immediately remove from active stack so passed or liked profiles never reappear
    setState(() {
      _activeProfiles.removeAt(0);
    });

    if (isMatch) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1F0A14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0xFFFF2D55), width: 1.5),
          ),
          title: const Text("It's a Vibe Match! 🎉",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(0xFFFF2D55), fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                  radius: 44, backgroundImage: AssetImage(profile.imagePath)),
              const SizedBox(height: 12),
              Text("You and ${profile.name} liked each other!",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Keep Swiping",
                  style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF2D55)),
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Say Hi 👋",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } else if (action == 'Liked' || action == 'Sparked') {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Liked ${profile.name}! Added to outgoing likes.'),
          duration: const Duration(milliseconds: 700),
          backgroundColor: const Color(0xFFD81B60),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_activeProfiles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('💖', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 14),
              const Text(
                'All Caught Up!',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                'You have explored all 35 unique profiles. Liked profiles are waiting in connections.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD81B60),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: _resetDeck,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text('Reset Discovery Stack',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    final profile = _activeProfiles.first;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Profile Photo
                  Image.asset(
                    profile.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                      color: const Color(0xFF1E2230),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.person,
                                size: 64, color: Colors.white38),
                            const SizedBox(height: 8),
                            Text(profile.name,
                                style: const TextStyle(
                                    fontSize: 20, color: Colors.white70)),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.2),
                          Colors.black.withValues(alpha: 0.9),
                        ],
                        stops: const [0.4, 0.65, 1.0],
                      ),
                    ),
                  ),

                  // Top badges
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: Color(0xFF00E5FF), size: 14),
                              const SizedBox(width: 4),
                              Text('${profile.distanceKm} km away',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [Color(0xFFFF2D55), Color(0xFF9B51E0)]),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.bolt,
                                  color: Colors.amber, size: 14),
                              const SizedBox(width: 4),
                              Text('${profile.vibeScore}% Vibe',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom info
                  Positioned(
                    bottom: 20,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${profile.name}, ${profile.age}',
                              style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            if (profile.isVerified) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.verified,
                                  color: Color(0xFF00E5FF), size: 20),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          profile.city,
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.8)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          profile.bio,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.white, height: 1.3),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: profile.interests.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Text(tag,
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.white)),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Action buttons row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ActionButton(
                icon: Icons.close,
                color: Colors.redAccent,
                size: 26,
                onTap: () => _nextProfile('Passed'),
              ),
              _ActionButton(
                icon: Icons.star,
                color: Colors.amber,
                size: 24,
                onTap: () => _nextProfile('Superliked'),
              ),
              _ActionButton(
                icon: Icons.favorite,
                color: const Color(0xFFFF2D55),
                size: 30,
                isPrimary: true,
                onTap: () => _nextProfile('Liked'),
              ),
              _ActionButton(
                icon: Icons.electric_bolt,
                color: const Color(0xFF00E5FF),
                size: 24,
                onTap: () => _nextProfile('Sparked'),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class ConnectStackScreen extends StatelessWidget {
  const ConnectStackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Likes You",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF2D55).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${demoProfiles.length} Available",
                  style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFFF2D55),
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Horizontal scroll of profiles who liked you
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: demoProfiles.length,
              itemBuilder: (ctx, idx) {
                final p = demoProfiles[idx];
                return Container(
                  width: 130,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color(0xFF0F121D),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(p.imagePath, fit: BoxFit.cover),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.85)
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        left: 8,
                        right: 8,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${p.name}, ${p.age}",
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              p.city.split('(').first.trim(),
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            "Mutual Matches",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Mutual matches list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 8,
            separatorBuilder: (ctx, idx) =>
                const Divider(color: Colors.white12, height: 16),
            itemBuilder: (ctx, idx) {
              final p = demoProfiles[idx];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 26,
                  backgroundImage: AssetImage(p.imagePath),
                ),
                title: Row(
                  children: [
                    Text(p.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (p.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified,
                          color: Color(0xFF00E5FF), size: 16),
                    ],
                    const Spacer(),
                    Text('${p.vibeScore}% Vibe',
                        style: const TextStyle(
                            color: Color(0xFFFF2D55),
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.phone,
                          color: Color(0xFF00E5FF), size: 20),
                      tooltip: 'Call ${p.name}',
                      onPressed: () {
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Starting WebRTC call with ${p.name}...'),
                            backgroundColor: const Color(0xFF00E5FF),
                            duration: const Duration(milliseconds: 900),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline,
                          color: Color(0xFFFF2D55), size: 20),
                      tooltip: 'Chat with ${p.name}',
                      onPressed: () {
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Opening chat with ${p.name}...'),
                            backgroundColor: const Color(0xFFFF2D55),
                            duration: const Duration(milliseconds: 900),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.size,
    this.isPrimary = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isPrimary ? 64 : 50,
        height: isPrimary ? 64 : 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF0F121D),
          border: Border.all(
            color: isPrimary ? color : color.withValues(alpha: 0.5),
            width: isPrimary ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: isPrimary ? 0.35 : 0.15),
              blurRadius: isPrimary ? 12 : 6,
            ),
          ],
        ),
        child: Icon(icon, color: color, size: size),
      ),
    );
  }
}
