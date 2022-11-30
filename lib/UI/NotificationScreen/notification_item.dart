import 'package:flutter/material.dart';

import '../../Utils/Colors.dart';

class NotificationItem extends StatelessWidget {
  const NotificationItem({
    Key? key,
    required this.data,
    required this.onDelete,
  }) : super(key: key);

  final Map data;
  final void Function(int id) onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
      tileColor: data["is_read"] == 0 ? commonColor.withOpacity(.1) : null,
      leading: const Icon(
        Icons.calendar_month,
        size: 30,
      ),
      title: Text(
        data["message"],
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: InkWell(
        onTap: () => onDelete(data["id"]),
        child: Icon(Icons.delete),
      ),
    );
  }
}
