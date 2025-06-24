import 'package:flutter/material.dart';

class AIHealthAssistantScreen extends StatefulWidget {
  const AIHealthAssistantScreen({super.key});

  @override
  State<AIHealthAssistantScreen> createState() =>
      _AIHealthAssistantScreenState();
}

class _AIHealthAssistantScreenState extends State<AIHealthAssistantScreen> {
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text:
          'Namaste! मैं आपका AI health assistant हूँ। आप मुझसे health के बारे में कुछ भी पूछ सकते हैं - Hinglish में भी! 😊',
      isUser: false,
      time: TimeOfDay.now(),
    ),
  ];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  final List<String> _quickQuestions = [
    'Fever ke liye kya karna chahiye?',
    'Khujli aur skin problems?',
    'Pet dard ka ilaj?',
    'Pregnancy mein kya khaana chahiye?',
    'Dengue ke lakshan?',
    'Cholera ka ilaj?',
    'Malaria se kaise bachein?',
    'Cough aur cold ka upay?',
    'Typhoid ke symptoms?',
    'Headache ka treatment?',
    'Vomiting/Diarrhea kya karein?',
  ];

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(
        _ChatMessage(text: text, isUser: true, time: TimeOfDay.now()),
      );
      _isLoading = true;
    });
    _controller.clear();
    Future.delayed(const Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
    _mockAIResponse(text);
  }

  void _mockAIResponse(String userText) {
    String response;
    final t = userText.toLowerCase();
    if (t.contains('fever')) {
      response =
          'Fever ke liye: Pani zyada piyen, aaram karein, aur zarurat ho toh paracetamol le sakte hain. Agar bukhar 3 din se zyada rahe toh doctor se milen.';
    } else if (t.contains('skin') || t.contains('khujli')) {
      response =
          'Skin/khujli ke liye: Safai ka dhyan rakhein, mild soap use karein, aur zyada khujli ho toh PHC ya doctor se sampark karein.';
    } else if (t.contains('pet')) {
      response =
          'Pet dard ke liye: Halka khana khayen, zyada dard ho toh doctor se milen. Bacchon mein pet dard ko lightly na lein.';
    } else if (t.contains('pregnancy')) {
      response =
          'Pregnancy mein: Poshtik khana khayen, iron/calcium lein, aur regular checkup karayen. Koi dikkat ho toh PHC se sampark karein.';
    } else if (t.contains('dengue')) {
      response =
          'Dengue ke lakshan: Tez bukhar, sar dard, aankhon ke peeche dard, joints/muscle pain, rashes. Pani piyen, aaram karein, aspirin na lein. Blood test aur doctor ki salah zaruri.';
    } else if (t.contains('cholera')) {
      response =
          'Cholera: Bahut zyada watery diarrhea, vomiting, dehydration. ORS piyen, safai ka dhyan rakhein, jaldi se doctor ya PHC se sampark karein.';
    } else if (t.contains('malaria')) {
      response =
          'Malaria: Bukhar, thand lagna, paseena, sar dard, ulti. Machhar se bachein, machhar daani use karein, bukhar ho toh blood test karayen.';
    } else if (t.contains('cough') ||
        t.contains('cold') ||
        t.contains('khansi') ||
        t.contains('zukaam')) {
      response =
          'Cough/cold: Garam paani piyen, rest karein, zyada khansi ho toh doctor se milen. Bacchon mein khansi ko lightly na lein.';
    } else if (t.contains('typhoid')) {
      response =
          'Typhoid: Bukhar, kamzori, pet dard, headache, kabhi kabhi rash. Doctor se milen, blood test karayen, antibiotics sirf doctor ki salah se lein.';
    } else if (t.contains('headache') || t.contains('sar dard')) {
      response =
          'Headache: Pani piyen, aaram karein, zyada dard ho toh doctor se milen. Agar headache ke sath bukhar, ulti, ya gardan akadna ho toh turant doctor se milen.';
    } else if (t.contains('vomiting') ||
        t.contains('diarrhea') ||
        t.contains('ulti') ||
        t.contains('dast')) {
      response =
          'Vomiting/Diarrhea: ORS piyen, halka khana khayen, dehydration se bachein. Bacchon mein dehydration ke lakshan dekhein (sookha muh, kam urine). Zyada ho toh doctor se milen.';
    } else {
      response =
          'Health के बारे में आपका सवाल समझ नहीं आया। कृपया specific symptoms बताएं या PHC contact करें। आप चाहें तो quick questions भी try कर सकते हैं! 😊';
    }
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add(
          _ChatMessage(text: response, isUser: false, time: TimeOfDay.now()),
        );
        _isLoading = false;
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [
          // Modern Gradient App Bar with Curve
          Stack(
            children: [
              ClipPath(
                clipper: _BottomCurveClipper(),
                child: Container(
                  height: 160,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4F8FFF), Color(0xFF8F5FFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'AI Health Assistant',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'First-Aid Tips in Hinglish',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 22,
                      child: Icon(
                        Icons.smart_toy,
                        color: Color(0xFF4F8FFF),
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                children: [
                  // Quick Questions
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    color: const Color(0xFFE3E8FF),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.help_outline,
                                color: Color(0xFF4F8FFF),
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Quick Questions / जल्दी पूछें',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children:
                                _quickQuestions
                                    .map(
                                      (q) => OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          side: const BorderSide(
                                            color: Color(0xFF4F8FFF),
                                          ),
                                        ),
                                        onPressed: () => _sendMessage(q),
                                        child: Text(
                                          q,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Chat Area
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.favorite,
                                  color: Color(0xFF8F5FFF),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Chat with AI / AI से बात करें',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: ListView.builder(
                                controller: _scrollController,
                                itemCount: _messages.length,
                                itemBuilder: (context, idx) {
                                  final msg = _messages[idx];
                                  return Align(
                                    alignment:
                                        msg.isUser
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            msg.isUser
                                                ? const Color(0xFF4F8FFF)
                                                : const Color(0xFFF8F9FB),
                                        borderRadius: BorderRadius.only(
                                          topLeft: const Radius.circular(16),
                                          topRight: const Radius.circular(16),
                                          bottomLeft: Radius.circular(
                                            msg.isUser ? 16 : 4,
                                          ),
                                          bottomRight: Radius.circular(
                                            msg.isUser ? 4 : 16,
                                          ),
                                        ),
                                        boxShadow: [
                                          if (!msg.isUser)
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.04,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            msg.isUser
                                                ? CrossAxisAlignment.end
                                                : CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            msg.text,
                                            style: TextStyle(
                                              color:
                                                  msg.isUser
                                                      ? Colors.white
                                                      : const Color(0xFF22223B),
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            msg.time.format(context),
                                            style: TextStyle(
                                              color:
                                                  msg.isUser
                                                      ? Colors.white70
                                                      : Colors.black38,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            if (_isLoading)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _controller,
                                    decoration: InputDecoration(
                                      hintText:
                                          'Type your question... / अपना सवाल लिखें...',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF4F8FFF),
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 10,
                                          ),
                                    ),
                                    onSubmitted: _sendMessage,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                CircleAvatar(
                                  backgroundColor: const Color(0xFF8F5FFF),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.send,
                                      color: Colors.white,
                                    ),
                                    onPressed:
                                        _isLoading
                                            ? null
                                            : () =>
                                                _sendMessage(_controller.text),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Modern curve clipper for app bar
class _BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final TimeOfDay time;
  _ChatMessage({required this.text, required this.isUser, required this.time});
}
