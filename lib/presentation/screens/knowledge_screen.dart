import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business_logic/providers/projects_provider.dart';
import '../../business_logic/providers/knowledge_provider.dart';
import '../widgets/knowledge_entry_card.dart';

class KnowledgeScreen extends StatefulWidget {
  const KnowledgeScreen({super.key});

  @override
  State<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends State<KnowledgeScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadKnowledgeEntries();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadKnowledgeEntries() async {
    final projectsProvider = Provider.of<ProjectsProvider>(context, listen: false);
    final knowledgeProvider = Provider.of<KnowledgeProvider>(context, listen: false);
    
    if (projectsProvider.currentProject != null) {
      await knowledgeProvider.loadEntries(projectsProvider.currentProject!.id);
    }
  }

  Future<void> _showCreateEntryDialog() async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String selectedCategory = 'insight';

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Knowledge Entry'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter title',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  hintText: 'Enter content',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                ),
                items: const [
                  DropdownMenuItem(value: 'insight', child: Text('Insight')),
                  DropdownMenuItem(value: 'rule', child: Text('Rule')),
                  DropdownMenuItem(value: 'pattern', child: Text('Pattern')),
                  DropdownMenuItem(value: 'preference', child: Text('Preference')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (value) {
                  if (value != null) selectedCategory = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isNotEmpty &&
                  contentController.text.trim().isNotEmpty) {
                final projectsProvider = Provider.of<ProjectsProvider>(context, listen: false);
                final knowledgeProvider = Provider.of<KnowledgeProvider>(context, listen: false);
                
                await knowledgeProvider.createEntry(
                  projectId: projectsProvider.currentProject!.id,
                  title: titleController.text.trim(),
                  content: contentController.text.trim(),
                  category: selectedCategory,
                );
                
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Knowledge Base'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search knowledge...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _loadKnowledgeEntries();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (query) {
                    final projectsProvider = Provider.of<ProjectsProvider>(context, listen: false);
                    final knowledgeProvider = Provider.of<KnowledgeProvider>(context, listen: false);
                    
                    if (query.isEmpty) {
                      knowledgeProvider.loadEntries(projectsProvider.currentProject!.id);
                    } else {
                      knowledgeProvider.searchEntries(projectsProvider.currentProject!.id, query);
                    }
                  },
                ),
              ),

              // Category Filter
              Consumer<KnowledgeProvider>(
                builder: (context, knowledgeProvider, child) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _buildCategoryChip('all', 'All', knowledgeProvider),
                        _buildCategoryChip('insight', 'Insights', knowledgeProvider),
                        _buildCategoryChip('rule', 'Rules', knowledgeProvider),
                        _buildCategoryChip('pattern', 'Patterns', knowledgeProvider),
                        _buildCategoryChip('preference', 'Preferences', knowledgeProvider),
                        _buildCategoryChip('other', 'Other', knowledgeProvider),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      body: Consumer<KnowledgeProvider>(
        builder: (context, knowledgeProvider, child) {
          if (knowledgeProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final entries = knowledgeProvider.filteredEntries;

          if (entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No knowledge entries yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first knowledge entry',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              return KnowledgeEntryCard(entry: entries[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateEntryDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryChip(String category, String label, KnowledgeProvider provider) {
    final isSelected = provider.selectedCategory == category;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          final projectsProvider = Provider.of<ProjectsProvider>(context, listen: false);
          provider.loadEntriesByCategory(projectsProvider.currentProject!.id, category);
        },
      ),
    );
  }
}
