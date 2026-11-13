import 'package:flutter/material.dart';
import 'models/medicine.dart';
import 'services/medicine_store.dart';
import 'family_page.dart';

void main() => runApp(const GPHealthApp());

const navy = Color(0xFF17364D);
const teal = Color(0xFF087E78);
const bg = Color(0xFFF2F7F8);

class GPHealthApp extends StatelessWidget {
  const GPHealthApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'GP Health',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: teal),
      scaffoldBackgroundColor: bg,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 18, color: navy),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 58),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    ),
    home: const MainScreen(),
  );
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final store = MedicineStore();
  final medicines = <Medicine>[];
  int tab = 0;
  bool loading = true;
  String? storageError;

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  Future<void> _loadMedicines() async {
    try {
      final saved = await store.load();
      if (!mounted) return;
      setState(() {
        medicines
          ..clear()
          ..addAll(saved);
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        storageError = 'Could not load saved medicines on this device.';
      });
    }
  }

  Future<void> _saveMedicines() async {
    try {
      await store.save(medicines);
      if (mounted) setState(() => storageError = null);
    } catch (_) {
      if (mounted) {
        setState(() => storageError = 'Could not save changes. Please check device storage.');
      }
    }
  }

  void notice(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> addMedicine() async {
    final name = TextEditingController();
    final time = TextEditingController(text: '9:00 AM');
    final note = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Add medicine'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: name, textCapitalization: TextCapitalization.sentences, decoration: const InputDecoration(labelText: 'Medicine name')),
            TextField(controller: time, decoration: const InputDecoration(labelText: 'Reminder time (e.g. 9:00 AM)')),
            TextField(controller: note, decoration: const InputDecoration(labelText: 'Notes (optional)')),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Save')),
        ],
      ),
    );
    if (saved == true && name.text.trim().isNotEmpty) {
      setState(() => medicines.add(Medicine(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name.text.trim(),
        time: time.text.trim().isEmpty ? 'Time not set' : time.text.trim(),
        note: note.text.trim(),
      )));
      await _saveMedicines();
    }
    name.dispose();
    time.dispose();
    note.dispose();
  }

  Future<void> toggleTaken(Medicine medicine) async {
    setState(() => medicine.taken = !medicine.taken);
    await _saveMedicines();
    if (mounted) notice(medicine.taken ? 'Marked as taken.' : 'Marked as not taken.');
  }

  @override
  Widget build(BuildContext context) {
    final pages = [_home(), _medicinePage(), _familyPage()];
    return Scaffold(
      appBar: AppBar(
        title: const Text('GP Health', style: TextStyle(fontWeight: FontWeight.w800, color: navy)),
        backgroundColor: bg,
      ),
      body: SafeArea(
        child: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
              if (storageError != null)
                MaterialBanner(
                  content: Text(storageError!),
                  actions: [TextButton(onPressed: _loadMedicines, child: const Text('Retry'))],
                ),
              Expanded(child: pages[tab]),
            ]),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (v) => setState(() => tab = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.medication_outlined), label: 'Medicines'),
          NavigationDestination(icon: Icon(Icons.family_restroom_outlined), label: 'Family'),
        ],
      ),
    );
  }

  Widget _home() => ListView(padding: const EdgeInsets.all(20), children: [
    const Text('Namaste! 👋', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: navy)),
    const SizedBox(height: 8),
    const Text('I am here to help you stay well and connected.', style: TextStyle(fontSize: 18, color: Color(0xFF526777))),
    const SizedBox(height: 22),
    Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: navy, borderRadius: BorderRadius.circular(24)),
      child: Column(children: [
        const Icon(Icons.mic, color: Colors.white, size: 50),
        const Text('Talk to AI', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text('Voice features are being built. Your medicine list works offline.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 16)),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => notice('Voice interaction is not enabled in this build yet.'),
          child: const Text('Start speaking', style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
      ]),
    ),
    const SizedBox(height: 20),
    Row(children: [
      Expanded(child: _tile(Icons.medication, 'My medicines', '${medicines.length} saved', teal, () => setState(() => tab = 1))),
      const SizedBox(width: 12),
      Expanded(child: _tile(Icons.call, 'Call family', 'Trusted contacts', const Color(0xFF4169A1), () => setState(() => tab = 2))),
    ]),
    const SizedBox(height: 14),
    SizedBox(height: 70, child: ElevatedButton.icon(
      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB3261E), foregroundColor: Colors.white),
      onPressed: () { setState(() => tab = 2); notice('Open Family & SOS to call your saved emergency contact.'); },
      icon: const Icon(Icons.sos, size: 28),
      label: const Text('EMERGENCY SOS', style: TextStyle(fontSize: 20)),
    )),
    const SizedBox(height: 20),
    const Text('Your medicines', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: navy)),
    if (medicines.isEmpty)
      const Card(color: Colors.white, child: ListTile(title: Text('No medicines added yet'), subtitle: Text('Tap My medicines to add your first reminder.')))
    else
      Card(color: Colors.white, child: ListTile(
        leading: const Icon(Icons.medication, color: teal, size: 32),
        title: Text(medicines.first.name),
        subtitle: Text('${medicines.first.time} · ${medicines.first.note}'),
      )),
  ]);

  Widget _tile(IconData icon, String title, String sub, Color color, VoidCallback tap) =>
    InkWell(
      onTap: tap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 145,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 34, color: color),
          const Spacer(),
          Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: navy)),
          Text(sub, style: const TextStyle(color: Color(0xFF526777))),
        ]),
      ),
    );

  Widget _medicinePage() => ListView(padding: const EdgeInsets.all(20), children: [
    const Text('My medicines', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: navy)),
    const SizedBox(height: 8),
    const Text('Your saved medicine list works on this device.', style: TextStyle(fontSize: 18)),
    const SizedBox(height: 14),
    if (medicines.isEmpty)
      const Card(color: Colors.white, child: Padding(padding: EdgeInsets.all(18), child: Text('No medicines yet. Add one below.', style: TextStyle(fontSize: 18))))
    else
      ...medicines.map((m) => Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.medication)),
              title: Text(m.name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
              subtitle: Text('${m.time}${m.note.isEmpty ? '' : ' · ${m.note}'}'),
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: () => toggleTaken(m),
                icon: Icon(m.taken ? Icons.check_circle : Icons.check),
                label: Text(m.taken ? 'Marked as taken' : 'Mark as taken'),
              ),
            ),
          ]),
        ),
      )),
    const SizedBox(height: 10),
    ElevatedButton.icon(onPressed: addMedicine, icon: const Icon(Icons.add), label: const Text('Add medicine')),
    const SizedBox(height: 10),
    const Text('Reminder alarms and dose history are the next development step. This version stores your list locally but does not yet send notifications.', style: TextStyle(color: Color(0xFF526777), height: 1.4)),
  ]);

  Widget _familyPage() => FamilyPage(onNotice: notice);
}
