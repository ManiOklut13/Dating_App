import 'package:flutter/material.dart';
import '../models/discovery_connect_models.dart';

class CoinStoreModal extends StatelessWidget {
  const CoinStoreModal({super.key});
  @override
  Widget build(BuildContext context) {
    final pkgs = [
      const RubyPackage(id:'p1', name:'Starter', rubies:100, bonus:0, priceInr:'₹99'),
      const RubyPackage(id:'p2', name:'Popular', rubies:500, bonus:50, priceInr:'₹399', popular:true),
      const RubyPackage(id:'p3', name:'Premium', rubies:1200, bonus:200, priceInr:'₹799'),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Buy Rubies / Unlock Unlimited Reverts 💎', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...pkgs.map((p) => ListTile(title: Text('${p.name} - ${p.rubies} Rubies', style: const TextStyle(color: Colors.white)), subtitle: Text(p.priceInr, style: const TextStyle(color: Colors.white70)), trailing: p.popular ? const Icon(Icons.star, color: Colors.amber) : null)),
      ]),
    );
  }
}