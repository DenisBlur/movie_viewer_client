import 'package:flutter/material.dart';
import 'package:movie_viewer/data/common.dart';
import 'package:movie_viewer/model/socket_provider.dart';
import 'package:provider/provider.dart';

class SessionItem extends StatelessWidget {
  const SessionItem({required this.session, super.key});

  final Session session;

  @override
  Widget build(BuildContext context) {

    bool canConnect = true;

    var sp = context.watch<SocketProvider>();
    if(sp.currentSession != null) {
      if(session.ownerSessionID == sp.currentSession!.ownerSessionID) {
        canConnect = false;

      } else {
        canConnect = true;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.only(right: 4, left: 16),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(.1), borderRadius: BorderRadius.circular(32)),
      child: Row(
        children: [
          Text(session.sessionName!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
          const Expanded(child: SizedBox()),
          Text("${session.connectedUsers!.length.toString()}/${session.maxUsers!.toString()}"),
          const SizedBox(width: 16,),
          if(canConnect) FilledButton(
            onPressed:() {
              context.read<SocketProvider>().connectToSession(session);
            },

            child: const Text("Connect"),
          ),
          if(!canConnect) const FilledButton(
            onPressed: null,
            child: Text("Connect"),
          ),
        ],
      ),
    );
  }
}
