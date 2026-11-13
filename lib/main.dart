import 'package:flutter/material.dart';

void main() => runApp(const GPHealthApp());

const navy = Color(0xFF17364D);
const teal = Color(0xFF087E78);
const bg = Color(0xFFF2F7F8);

class GPHealthApp extends StatelessWidget {
  const GPHealthApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'GP Health', debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: teal), scaffoldBackgroundColor: bg),
    home: const MainScreen(),
  );
}

class Medicine {
  Medicine(this.name, this.time, this.note);
  final String name, time, note;
  bool taken = false;
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int tab = 0;
  final medicines = <Medicine>[Medicine('Morning tablet', '8:00 AM', 'After breakfast'), Medicine('Evening medicine', '8:00 PM', 'After dinner')];

  void notice(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  Future<void> addMedicine() async {
    final name = TextEditingController(), time = TextEditingController(text: '9:00 AM'), note = TextEditingController();
    final saved = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      title: const Text('Add medicine'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: 'Medicine name')),
        TextField(controller: time, decoration: const InputDecoration(labelText: 'Reminder time')),
        TextField(controller: note, decoration: const InputDecoration(labelText: 'Notes')),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Save'))],
    ));
    if (saved == true && name.text.trim().isNotEmpty) setState(() => medicines.add(Medicine(name.text.trim(), time.text.trim(), note.text.trim())));
    name.dispose(); time.dispose(); note.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _home(),
      _medicinePage(),
      _familyPage(),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('GP Health', style: TextStyle(fontWeight: FontWeight.w800, color: navy)), backgroundColor: bg),
      body: SafeArea(child: pages[tab]),
      bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (v) => setState(() => tab = v), destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.medication_outlined), label: 'Medicines'),
        NavigationDestination(icon: Icon(Icons.family_restroom_outlined), label: 'Family'),
      ]),
    );
  }

  Widget _home() => ListView(padding: const EdgeInsets.all(20), children: [
    const Text('Namaste! 👋', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: navy)),
    const SizedBox(height: 8),
    const Text('I am here to help you stay well and connected.', style: TextStyle(fontSize: 18, color: Color(0xFF526777))),
    const SizedBox(height: 22),
    Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: navy, borderRadius: BorderRadius.circular(24)), child: Column(children: [
      const Icon(Icons.mic, color: Colors.white, size: 50),
      const Text('Talk to AI', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      const Text('Voice assistant setup is coming soon', style: TextStyle(color: Colors.white70, fontSize: 16)),
      const SizedBox(height: 12),
      OutlinedButton(onPressed: () => notice('Voice interaction will be enabled in a later milestone.'), child: const Text('Start speaking', style: TextStyle(color: Colors.white, fontSize: 18))),
    ])),
    const SizedBox(height: 20),
    Row(children: [
      Expanded(child: _tile(Icons.medication, 'My medicines', 'Manage reminders', teal, () => setState(() => tab = 1))),
      const SizedBox(width: 12),
      Expanded(child: _tile(Icons.call, 'Call family', 'Stay connected', const Color(0xFF4169A1), () => setState(() => tab = 2))),
    ]),
    const SizedBox(height: 14),
    SizedBox(height: 70, child: ElevatedButton.icon(
      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB3261E), foregroundColor: Colors.white),
      onPressed: () => showDialog(context: context, builder: (c) => AlertDialog(
        title: const Text('Emergency help'),
        content: const Text('Would you like to continue to your saved emergency contact? A call will only be placed after confirmation.'),
        actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')), FilledButton(onPressed: () { Navigator.pop(c); notice('Emergency contact setup is not implemented yet. No call was placed.'); }, child: const Text('Continue'))],
      )),
      icon: const Icon(Icons.sos, size: 28), label: const Text('EMERGENCY SOS', style: TextStyle(fontSize: 20)),
    )),
    const SizedBox(height: 20),
    const Text('Next reminder', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: navy)),
    if (medicines.isNotEmpty) Card(color: Colors.white, child: ListTile(leading: const Icon(Icons.alarm, color: teal, size: 32), title: Text(medicines.first.name), subtitle: Text('${medicines.first.time} · ${medicines.first.note}'))),
  ]);

  Widget _tile(IconData icon, String title, String sub, Color color, VoidCallback tap) => InkWell(onTap: tap, borderRadius: BorderRadius.circular(20), child: Container(height: 145, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, size: 34, color: color), const Spacer(), Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: navy)), Text(sub, style: const TextStyle(color: Color(0xFF526777)))])));

  Widget _medicinePage() => ListView(padding: const EdgeInsets.all(20), children: [
    const Text('My medicines', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: navy)),
    const SizedBox(height: 8), const Text('Your medicine list', style: TextStyle(fontSize: 18)),
    const SizedBox(height: 14),
    ...medicines.map((m) => Card(color: Colors.white, child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
      ListTile(leading: const CircleAvatar(child: Icon(Icons.medication)), title: Text(m.name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)), subtitle: Text('${m.time} · ${m.note}')),
      SizedBox(width: double.infinity, child: FilledButton.tonalIcon(onPressed: () => setState(() => m.taken = !m.taken), icon: Icon(m.taken ? Icons.check_circle : Icons.check), label: Text(m.taken ? 'Marked as taken' : 'Mark as taken'))),
    ])))),
    const SizedBox(height: 10),
    ElevatedButton.icon(onPressed: addMedicine, icon: const Icon(Icons.add), label: const Text('Add medicine')),
    const SizedBox(height: 10),
    const Text('Prototype note: reminders are not yet scheduled or saved after closing the app.', style: TextStyle(color: Color(0xFF526777))),
  ]);

  Widget _familyPage() => ListView(padding: const EdgeInsets.all(20), children: [
    const Text('Family & SOS', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: navy)),
    const SizedBox(height: 8), const Text('Keep your trusted people close.', style: TextStyle(fontSize: 18)),
    const SizedBox(height: 18),
    Card(color: Colors.white, child: ListTile(leading: const CircleAvatar(child: Icon(Icons.person)), title: const Text('No family contacts yet', style: TextStyle(fontWeight: FontWeight.bold)), subtitle: const Text('Contact setup is coming next.'), trailing: IconButton(onPressed: () => notice('Family contact setup is not implemented yet.'), icon: const Icon(Icons.add_circle_outline)))),
    const SizedBox(height: 16),
    const Text('Safety', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: navy)),
    const Text('Emergency calls will require your confirmation. This prototype does not place calls or share your location.', style: TextStyle(fontSize: 17, height: 1.4)),
  ]);
}
