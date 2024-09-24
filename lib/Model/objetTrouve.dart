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
      date: json['date'],
      dateRestitution: json['gc_obo_date_heure_restitution_c'],
      gareOrigine: json['gc_obo_gare_origine_r_name'],
      codeUICGare: json['gc_obo_gare_origine_r_code_uic_c'],
      nature: json['gc_obo_nature_c'],
      type: json['gc_obo_type_c'],
      nomTypeObjet: json['gc_obo_nom_recordtype_sc_c'],
    );
  }
}
