import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/family_contact.dart';
import 'services/contact_store.dart';

const _navy = Color(0xFF17364D);
const _teal = Color(0xFF087E78);

class FamilyPage extends StatefulWidget {
  const FamilyPage({super.key, required this.onNotice});
  final void Function(String) onNotice;

  @override
  State<FamilyPage> createState() => _FamilyPageState();
}

class _FamilyPageState extends State<FamilyPage> {
  final _store = ContactStore();
  final _contacts = <FamilyContact>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final saved = await _store.load();
      if (!mounted) return;
      setState(() {
        _contacts
          ..clear()
          ..addAll(saved);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      widget.onNotice('Could not load saved contacts.');
    }
  }

  Future<void> _save() async {
    try {
      await _store.save(_contacts);
    } catch (_) {
      widget.onNotice('Could not save contacts on this device.');
    }
  }

  Future<void> _addContact() async {
    final name = TextEditingController();
    final phone = TextEditingController();
    bool emergency = _contacts.every((contact) => !contact.isEmergency);
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add family contact'),
          content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: name, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone number')),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: emergency,
              onChanged: (value) => setDialogState(() => emergency = value ?? false),
              title: const Text('Use as emergency contact'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ])),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Save')),
          ],
        ),
      ),
    );

    final digits = phone.text.replaceAll(RegExp(r'[^0-9+]'), '');
    if (result == true) {
      if (name.text.trim().isEmpty || digits.replaceAll('+', '').length < 7) {
        widget.onNotice('Enter a name and a valid phone number.');
      } else {
        setState(() {
          if (emergency) {
            for (final contact in _contacts) {
              contact.isEmergency = false;
            }
          }
          _contacts.add(FamilyContact(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            name: name.text.trim(),
            phone: digits,
            isEmergency: emergency,
          ));
        });
        await _save();
      }
    }
    name.dispose();
    phone.dispose();
  }

  Future<void> _setEmergency(FamilyContact selected) async {
    setState(() {
      for (final contact in _contacts) {
        contact.isEmergency = contact.id == selected.id;
      }
    });
    await _save();
    widget.onNotice('${selected.name} is now your emergency contact.');
  }

  Future<void> _call(FamilyContact contact) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Call ${contact.name}?'),
        content: Text('GP Health will open your phone app for ${contact.phone}. Confirm before the call proceeds.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Open phone')),
        ],
      ),
    );
    if (confirmed != true) return;
    final uri = Uri(scheme: 'tel', path: contact.phone);
    final opened = await launchUrl(uri);
    if (!opened && mounted) widget.onNotice('Could not open the phone app on this device.');
  }

  Future<void> _callEmergency() async {
    FamilyContact? contact;
    for (final item in _contacts) {
      if (item.isEmergency) {
        contact = item;
        break;
      }
    }
    if (contact == null) {
      widget.onNotice('Add a family contact and mark them as your emergency contact first.');
      return;
    }
    await _call(contact);
  }

  Future<void> _delete(FamilyContact contact) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Remove contact?'),
        content: Text('Remove ${contact.name} from this device?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Remove')),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() => _contacts.removeWhere((item) => item.id == contact.id));
      await _save();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return ListView(padding: const EdgeInsets.all(20), children: [
      const Text('Family & SOS', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: _navy)),
      const SizedBox(height: 8),
      const Text('Your trusted people, saved on this device.', style: TextStyle(fontSize: 18)),
      const SizedBox(height: 16),
      if (_contacts.isEmpty)
        const Card(color: Colors.white, child: Padding(padding: EdgeInsets.all(18), child: Text('No family contacts yet. Add someone you trust.', style: TextStyle(fontSize: 17))))
      else
        ..._contacts.map((contact) => Card(
          color: Colors.white,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFE0F2F1),
              child: Icon(contact.isEmergency ? Icons.emergency : Icons.person, color: _teal),
            ),
            title: Text(contact.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            subtitle: Text('${contact.phone}${contact.isEmergency ? ' · Emergency contact' : ''}'),
            trailing: PopupMenuButton<String>(
              tooltip: 'Contact options',
              onSelected: (value) {
                if (value == 'call') _call(contact);
                if (value == 'emergency') _setEmergency(contact);
                if (value == 'delete') _delete(contact);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'call', child: Text('Call')),
                if (!contact.isEmergency) const PopupMenuItem(value: 'emergency', child: Text('Set as emergency contact')),
                const PopupMenuItem(value: 'delete', child: Text('Remove contact')),
              ],
            ),
            onTap: () => _call(contact),
          ),
        )),
      const SizedBox(height: 8),
      ElevatedButton.icon(onPressed: _addContact, icon: const Icon(Icons.person_add_alt_1), label: const Text('Add family contact')),
      const SizedBox(height: 12),
      SizedBox(
        height: 64,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB3261E), foregroundColor: Colors.white),
          onPressed: _callEmergency,
          icon: const Icon(Icons.sos, size: 28),
          label: const Text('CALL EMERGENCY CONTACT', style: TextStyle(fontSize: 17)),
        ),
      ),
      const SizedBox(height: 14),
      const Text('Safety: GP Health asks you to confirm before opening the phone app. It does not automatically contact emergency services or share your location.', style: TextStyle(fontSize: 16, height: 1.4, color: Color(0xFF526777))),
    ]);
  }
}
