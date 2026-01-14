import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/event_model.dart';
import '../models/ai_model.dart';
import '../providers/event_provider.dart';
import '../providers/auth_provider.dart';
import '../services/ai_service.dart';

class EventFormScreen extends StatefulWidget {
  final Event? event;

  const EventFormScreen({super.key, this.event});

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _agendaController;
  late TextEditingController _dateController;
  EventState _selectedStatus = EventState.draft;
  DateTime _selectedDate = DateTime.now();
  bool _isGeneratingContent = false;
  bool _isGeneratingMarketing = false;

  bool get isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.event?.titleEvenement ?? '');
    _descriptionController =
        TextEditingController(text: widget.event?.descriptionEvenement ?? '');
    _locationController =
        TextEditingController(text: widget.event?.location ?? '');
    _agendaController = TextEditingController(text: widget.event?.agenda ?? '');

    if (widget.event != null) {
      try {
        _selectedDate = DateTime.parse(widget.event!.dateEvenement);
      } catch (e) {
        _selectedDate = DateTime.now();
      }
      _selectedStatus = widget.event!.statusEvenement;
    }

    _updateDateController();
  }

  void _updateDateController() {
    _dateController = TextEditingController(
      text: '${_selectedDate.day.toString().padLeft(2, '0')}/'
          '${_selectedDate.month.toString().padLeft(2, '0')}/'
          '${_selectedDate.year} '
          '${_selectedDate.hour.toString().padLeft(2, '0')}:'
          '${_selectedDate.minute.toString().padLeft(2, '0')}',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _agendaController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _updateDateController();
        });
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final eventProvider = context.read<EventProvider>();
      final authProvider = context.read<AuthProvider>();

      final dateString = _selectedDate.toIso8601String();

      bool success;
      if (isEditing) {
        final updatedEvent = widget.event!.copyWith(
          titleEvenement: _titleController.text.trim(),
          descriptionEvenement: _descriptionController.text.trim(),
          location: _locationController.text.trim(),
          dateEvenement: dateString,
          statusEvenement: _selectedStatus,
          agenda: _agendaController.text.trim(),
        );
        success = await eventProvider.updateEvent(updatedEvent);
      } else {
        final request = CreateEventRequest(
          organizerID: authProvider.user?.id ?? 1,
          titleEvenement: _titleController.text.trim(),
          descriptionEvenement: _descriptionController.text.trim(),
          location: _locationController.text.trim(),
          dateEvenement: dateString,
          statusEvenement: _selectedStatus,
          agenda: _agendaController.text.trim(),
        );
        success = await eventProvider.createEvent(request);
      }

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditing
                  ? 'Événement modifié avec succès'
                  : 'Événement créé avec succès'),
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(eventProvider.error ?? 'Une erreur est survenue'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _generateEventContent() async {
    setState(() => _isGeneratingContent = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final aiService = AIService(token: authProvider.token);

      // Envoie TOUTES les informations saisies au backend
      print('DEBUG - Envoi au backend:');
      print('  Titre: ${_titleController.text.trim()}');
      print('  Description: ${_descriptionController.text.trim()}');
      print('  Lieu: ${_locationController.text.trim()}');
      print('  Date: ${_selectedDate.toIso8601String()}');
      print('  Agenda: ${_agendaController.text.trim()}');

      final content = await aiService.generateEventContent(
        prompt: EventDataPrompt(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          location: _locationController.text.trim(),
          eventDate: _selectedDate.toIso8601String(),
          agenda: _agendaController.text.trim(),
        ),
      );

      // REMPLACE TOUJOURS le contenu avec celui généré par l'IA
      setState(() {
        _titleController.text = content.title;
        _descriptionController.text = content.description;
        _agendaController.text = content.agenda;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contenu généré et remplacé avec succès par l\'IA !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isGeneratingContent = false);
    }
  }

  Future<void> _generateMarketing() async {
    setState(() => _isGeneratingMarketing = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final aiService = AIService(token: authProvider.token);

      final marketing = await aiService.generateMarketing(
        prompt: MarketingDataPrompt(
          title: _titleController.text.trim(),
          location: _locationController.text.trim(),
          eventDate: _selectedDate.toIso8601String(),
        ),
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.campaign, color: Colors.purple.shade700),
                const SizedBox(width: 8),
                const Text('Contenu Marketing'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: SelectableText(
                      marketing,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade900,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '💡 Copiez ce texte pour vos réseaux sociaux',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: marketing));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Contenu copié dans le presse-papiers !'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copier pour réseaux sociaux'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isGeneratingMarketing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier l\'événement' : 'Nouvel événement'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // AI Generation Section
            Card(
              color: Colors.purple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.purple.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Génération IA',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple.shade700,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Laissez l\'IA vous aider à créer du contenu professionnel',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isGeneratingContent
                                ? null
                                : _generateEventContent,
                            icon: _isGeneratingContent
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Icon(Icons.auto_awesome),
                            label: Text(_isGeneratingContent
                                ? 'Génération...'
                                : 'Générer le contenu'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isGeneratingMarketing
                                ? null
                                : _generateMarketing,
                            icon: _isGeneratingMarketing
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Icon(Icons.campaign),
                            label: Text(_isGeneratingMarketing
                                ? 'Génération...'
                                : 'Marketing'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.purple,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titre *',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Le titre est requis';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description *',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La description est requise';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Date
            TextFormField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'Date et heure *',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: _selectDate,
            ),
            const SizedBox(height: 16),

            // Location
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Lieu *',
                prefixIcon: Icon(Icons.location_on),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Le lieu est requis';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Status
            DropdownButtonFormField<EventState>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Statut *',
                prefixIcon: Icon(Icons.flag),
              ),
              items: EventState.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.label),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedStatus = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Agenda
            TextFormField(
              controller: _agendaController,
              decoration: const InputDecoration(
                labelText: 'Agenda',
                prefixIcon: Icon(Icons.list_alt),
                hintText: 'Programme détaillé de l\'événement',
              ),
              maxLines: 6,
            ),
            const SizedBox(height: 24),

            // Submit Button
            Consumer<EventProvider>(
              builder: (context, provider, child) {
                return SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: provider.isLoading ? null : _handleSubmit,
                    icon: provider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(isEditing ? Icons.save : Icons.add),
                    label: Text(
                      isEditing ? 'Enregistrer' : 'Créer l\'événement',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
