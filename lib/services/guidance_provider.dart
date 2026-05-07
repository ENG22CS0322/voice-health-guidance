import 'package:flutter/foundation.dart';

class GuidanceSection {
  final String title;
  final List<String> points;

  GuidanceSection({required this.title, required this.points});
}

class GuidanceResponse {
  final String guidance;
  final GuidanceSection emergencyGuidance;
  final GuidanceSection immediateSteps;
  final GuidanceSection whenToCall;
  final GuidanceSection importantNote;

  GuidanceResponse({
    required this.guidance,
    required this.emergencyGuidance,
    required this.immediateSteps,
    required this.whenToCall,
    required this.importantNote,
  });
}

class GuidanceProvider extends ChangeNotifier {
  final Map<String, GuidanceResponse> _offlineKnowledgeBase = {
    'Fever': GuidanceResponse(
      guidance: 'Manage high body temperature safely.',
      emergencyGuidance: GuidanceSection(title: 'EMERGENCY GUIDANCE', points: [
        'High fever is common but needs careful monitoring.',
        'Extremely high fever (above 104°F) can be dangerous.'
      ]),
      immediateSteps: GuidanceSection(title: 'IMMEDIATE STEPS', points: [
        '1. Rest in a cool, well-ventilated room.',
        '2. Drink plenty of water and ORS to stay hydrated.',
        '3. Use a cool, damp cloth on the forehead to lower temperature.',
        '4. Wear light, breathable cotton clothing.'
      ]),
      whenToCall: GuidanceSection(title: 'WHEN TO CALL FOR HELP', points: [
        'If fever exceeds 104°F or lasts more than 3 days.',
        'If accompanied by severe headache, stiff neck, or seizures.',
        'Call 108 or visit the nearest Primary Health Centre.'
      ]),
      importantNote: GuidanceSection(title: 'IMPORTANT NOTE', points: [
        'This is general guidance. Please seek professional medical help if symptoms persist.'
      ]),
    ),
    'Snake Bite': GuidanceResponse(
      guidance: 'Act fast but stay calm after a snake bite.',
      emergencyGuidance: GuidanceSection(title: 'EMERGENCY GUIDANCE', points: [
        'Any snake bite should be treated as a medical emergency.',
        'Do NOT waste time trying to catch or identify the snake.'
      ]),
      immediateSteps: GuidanceSection(title: 'IMMEDIATE STEPS', points: [
        '1. Keep the bitten limb below Heart level and stay still.',
        '2. Remove tight jewelry or clothing near the bite.',
        '3. Clean the bite with soap and water if available.',
        '4. Do NOT cut the wound or try to suck out the venom.'
      ]),
      whenToCall: GuidanceSection(title: 'WHEN TO CALL FOR HELP', points: [
        'Immediately call 108 or go to a hospital with anti-venom.',
        'Do not use traditional "jhad-phook" or local healers.'
      ]),
      importantNote: GuidanceSection(title: 'IMPORTANT NOTE', points: [
        'This is general guidance. Please seek professional medical help immediately.'
      ]),
    ),
    'Stomach Pain': GuidanceResponse(
      guidance: 'Handling abdominal discomfort and cramps.',
      emergencyGuidance: GuidanceSection(title: 'EMERGENCY GUIDANCE', points: [
        'Stomach pain can range from simple gas to serious infection.',
        'Intense, sudden pain requires immediate attention.'
      ]),
      immediateSteps: GuidanceSection(title: 'IMMEDIATE STEPS', points: [
        '1. Lie down and rest in a comfortable position.',
        '2. Sip warm water slowly.',
        '3. Avoid eating solid food for a few hours.',
        '4. Monitor for vomiting or blood in stool.'
      ]),
      whenToCall: GuidanceSection(title: 'WHEN TO CALL FOR HELP', points: [
        'If pain is localized in the lower right abdomen (Appedicitis risk).',
        'If pain is accompanied by high fever or severe vomiting.',
        'Go to the nearest clinic or call 108.'
      ]),
      importantNote: GuidanceSection(title: 'IMPORTANT NOTE', points: [
        'This is general guidance. Please seek professional medical help if pain worsens.'
      ]),
    ),
    'Dehydration': GuidanceResponse(
      guidance: 'Maintaining body fluids during heat or diarrhea.',
      emergencyGuidance: GuidanceSection(title: 'EMERGENCY GUIDANCE', points: [
        'Loss of body fluids is a major cause of weakness and fainting in rural settings.',
        'Extreme thirst and dry mouth are primary signs.'
      ]),
      immediateSteps: GuidanceSection(title: 'IMMEDIATE STEPS', points: [
        '1. Drink Oral Rehydration Solution (ORS) immediately.',
        '2. If ORS is not available, mix 6 tsp sugar and 1/2 tsp salt in 1 liter clean water.',
        '3. Drink coconut water or lime water.',
        '4. Stay in the shade or a cool area.'
      ]),
      whenToCall: GuidanceSection(title: 'WHEN TO CALL FOR HELP', points: [
        'If the person is unconscious or cannot drink fluids.',
        'If there is no urination for more than 8 hours.',
        'Call 108 or reach the PHC quickly.'
      ]),
      importantNote: GuidanceSection(title: 'IMPORTANT NOTE', points: [
        'This is general guidance. Please seek professional medical help immediately.'
      ]),
    ),
  };

  GuidanceResponse? _currentGuidance;
  GuidanceResponse? get currentGuidance => _currentGuidance;

  void fetchGuidance(String symptom) {
    _currentGuidance = _offlineKnowledgeBase[symptom] ?? _offlineKnowledgeBase['Fever'];
    notifyListeners();
  }

  void clearGuidance() {
    _currentGuidance = null;
    notifyListeners();
  }

  String getResponseFromInput(String userInput) {
    userInput = userInput.toLowerCase();

    if (userInput.contains("fever")) {
      return "You may have a fever. Drink fluids and take rest.";
    } 
    else if (userInput.contains("headache")) {
      return "For headache, rest and stay hydrated.";
    } 
    else if (userInput.contains("cold")) {
      return "It might be a common cold. Keep yourself warm.";
    } 
    else {
      return "Sorry, I could not understand. Please consult a doctor if symptoms persist.";
    }
  }
}
