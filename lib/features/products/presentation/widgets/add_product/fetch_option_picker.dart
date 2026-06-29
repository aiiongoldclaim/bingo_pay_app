import 'package:flutter/material.dart';

/// Returns `(id, name)` record for the selected item, or null if dismissed.
Future<({String id, String name})?> showFetchOptionPickerById<T>(
  BuildContext context, {
  required String title,
  required Future<List<T>> Function() fetch,
  required String Function(T) nameOf,
  required String Function(T) idOf,
  String? selectedId,
}) {
  return showModalBottomSheet<({String id, String name})>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: _FetchOptionPickerByIdContent<T>(
        title: title,
        fetch: fetch,
        nameOf: nameOf,
        idOf: idOf,
        selectedId: selectedId,
      ),
    ),
  );
}

class _FetchOptionPickerByIdContent<T> extends StatefulWidget {
  final String title;
  final Future<List<T>> Function() fetch;
  final String Function(T) nameOf;
  final String Function(T) idOf;
  final String? selectedId;

  const _FetchOptionPickerByIdContent({
    required this.title,
    required this.fetch,
    required this.nameOf,
    required this.idOf,
    this.selectedId,
  });

  @override
  State<_FetchOptionPickerByIdContent<T>> createState() =>
      _FetchOptionPickerByIdContentState<T>();
}

class _FetchOptionPickerByIdContentState<T>
    extends State<_FetchOptionPickerByIdContent<T>> {
  late final Future<List<T>> _future = widget.fetch();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          FutureBuilder<List<T>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Text('Failed to load options: ${snapshot.error}'),
                );
              }
              final options = snapshot.data ?? const [];
              return Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final option in options)
                      ListTile(
                        title: Text(widget.nameOf(option)),
                        trailing: widget.idOf(option) == widget.selectedId
                            ? const Icon(Icons.check, color: Colors.blue)
                            : null,
                        onTap: () => Navigator.of(context).pop(
                          (id: widget.idOf(option), name: widget.nameOf(option)),
                        ),
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

Future<String?> showFetchOptionPicker<T>(
  BuildContext context, {
  required String title,
  required Future<List<T>> Function() fetch,
  required String Function(T) nameOf,
  String? selected,
}) {
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: _FetchOptionPickerContent<T>(title: title, fetch: fetch, nameOf: nameOf, selected: selected),
    ),
  );
}

class _FetchOptionPickerContent<T> extends StatefulWidget {
  final String title;
  final Future<List<T>> Function() fetch;
  final String Function(T) nameOf;
  final String? selected;

  const _FetchOptionPickerContent({required this.title, required this.fetch, required this.nameOf, this.selected});

  @override
  State<_FetchOptionPickerContent<T>> createState() => _FetchOptionPickerContentState<T>();
}

class _FetchOptionPickerContentState<T> extends State<_FetchOptionPickerContent<T>> {
  late final Future<List<T>> _future = widget.fetch();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          FutureBuilder<List<T>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Text('Failed to load options: ${snapshot.error}'),
                );
              }
              final options = snapshot.data ?? const [];
              return Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final option in options)
                      ListTile(
                        title: Text(widget.nameOf(option)),
                        trailing: widget.nameOf(option) == widget.selected
                            ? const Icon(Icons.check, color: Colors.blue)
                            : null,
                        onTap: () => Navigator.of(context).pop(widget.nameOf(option)),
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
