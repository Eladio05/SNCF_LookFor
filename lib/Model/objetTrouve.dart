class ObjetTrouve {
  final String date;
  final String? dateRestitution;
  final String gareOrigine;
  final String codeUICGare;
  final String nature;
  final String type;
  final String nomTypeObjet;

  ObjetTrouve({
    required this.date,
    this.dateRestitution,
    required this.gareOrigine,
    required this.codeUICGare,
    required this.nature,
    required this.type,
    required this.nomTypeObjet,
  });

  factory ObjetTrouve.fromJson(Map<String, dynamic> json) {
    return ObjetTrouve(
      date: json['date'] != null ? json['date'].toString() : 'Date inconnue',
      dateRestitution: json['gc_obo_date_heure_restitution_c'] != null
          ? json['gc_obo_date_heure_restitution_c'].toString()
          : null,
      gareOrigine: json['gc_obo_gare_origine_r_name'] != null
          ? json['gc_obo_gare_origine_r_name'].toString()
          : 'Gare inconnue',
      codeUICGare: json['gc_obo_gare_origine_r_code_uic_c'] != null
          ? json['gc_obo_gare_origine_r_code_uic_c'].toString()
          : 'Code UIC inconnu',
      nature: json['gc_obo_nature_c'] != null
          ? json['gc_obo_nature_c'].toString()
          : 'Nature inconnue',
      type: json['gc_obo_type_c'] != null
          ? json['gc_obo_type_c'].toString()
          : 'Type inconnu',
      nomTypeObjet: json['gc_obo_nom_recordtype_sc_c'] != null
          ? json['gc_obo_nom_recordtype_sc_c'].toString()
          : 'Nom de type inconnu',
    );
  }
}
