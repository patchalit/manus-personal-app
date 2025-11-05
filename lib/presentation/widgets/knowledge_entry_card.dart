import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/knowledge_entry_model.dart';
import '../../business_logic/providers/knowledge_provider.dart';

class KnowledgeEntryCard extends StatelessWidget {
  final KnowledgeEntryModel entry;

  const KnowledgeEntryCard({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showEntryDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Category
              Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildCategoryBadge(entry.category),
                ],
              ),
              const SizedBox(height: 8),

              // Content Preview
              Text(
                entry.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),

              // Tags and Date
              Row(
                children: [
                  if (entry.tags.isNotEmpty) ...[
                    Expanded(
                      child: Wrap(
                        spacing: 4,
                        children: entry.tags.take(3).map((tag) {
                          return Chip(
                            label: Text(
                              tag,
                              style: const TextStyle(fontSize: 11),
                            ),
                            padding: const EdgeInsets.all(2),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                  Text(
                    _formatDate(entry.createdAt),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(String? category) {
    if (category == null) return const SizedBox.shrink();

    Color color;
    IconData icon;

    switch (category) {
      case 'insight':
        color = Colors.blue;
        icon = Icons.lightbulb;
        break;
      case 'rule':
        color = Colors.orange;
        icon = Icons.rule;
        break;
      case 'pattern':
        color = Colors.purple;
        icon = Icons.pattern;
        break;
      case 'preference':
        color = Colors.green;
        icon = Icons.favorite;
        break;
      default:
        color = Colors.grey;
        icon = Icons.label;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            category,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showEntryDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Expanded(child: Text(entry.title)),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final confirmed = await _showDeleteConfirmation(context);
                if (confirmed && context.mounted) {
                  final knowledgeProvider = Provider.of<KnowledgeProvider>(context, listen: false);
                  await knowledgeProvider.deleteEntry(entry.id);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCategoryBadge(entry.category),
              const SizedBox(height: 16),
              Text(
                entry.content,
                style: const TextStyle(fontSize: 15),
              ),
              if (entry.tags.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Tags:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: entry.tags.map((tag) {
                    return Chip(label: Text(tag));
                  }).toList(),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                'Created: ${_formatDate(entry.createdAt)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this knowledge entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
