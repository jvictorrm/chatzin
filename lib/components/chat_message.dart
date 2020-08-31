import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  final Map<String, dynamic> _data;
  final bool _isUserDevice;

  ChatMessage(this._data, this._isUserDevice);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: Row(
        children: [
          !_isUserDevice
              ? Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(_data['senderPhotoUrl']),
                  ))
              : Container(),
          Expanded(
              child: Column(
            crossAxisAlignment: _isUserDevice
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              _buildContentMessage(),
              Text(_data['senderName'],
                  textAlign: _isUserDevice ? TextAlign.end : TextAlign.start,
                  style: TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.white)),
            ],
          )),
          _isUserDevice
              ? Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(_data['senderPhotoUrl']),
                  ))
              : Container(),
        ],
      ),
    );
  }

  Widget _buildContentMessage() {
    return _data['file'] != null
        ? Image.network(
            _data['file'],
            width: 250.0,
          )
        : Text(
            _data['text'],
            style: TextStyle(fontSize: 16.0, color: Colors.white),
          );
  }
}
