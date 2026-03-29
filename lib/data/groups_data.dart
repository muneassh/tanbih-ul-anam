import 'package:flutter/material.dart';

class SalawatGroup {
  final int id;
  final String nameAr;
  final String nameEn;
  final IconData icon;
  final Color color;
  final String descriptionAr;
  final String descriptionEn;
  final List<int> salawatIds;
  final List<String> keywords;

  SalawatGroup({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.icon,
    required this.color,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.salawatIds,
    required this.keywords,
  });
}

class GroupsData {
  static List<SalawatGroup> getGroups() {
    return [
      // 1. Marriage Group
      SalawatGroup(
        id: 1,
        nameAr: 'النكاح',
        nameEn: 'Marriage',
        icon: Icons.favorite,
        color: const Color(0xFFE91E63),
        descriptionAr: 'صلوات مباركة لطلب الزواج والبركة في الزواج واستقرار الأسرة',
        descriptionEn: 'Blessed prayers for seeking marriage, marital blessings, and family stability',
        salawatIds: [],
        keywords: [],
      ),
      
      // 2. Healing Group
      SalawatGroup(
        id: 2,
        nameAr: 'الشفاء',
        nameEn: 'Healing',
        icon: Icons.local_hospital,
        color: const Color(0xFF4CAF50),
        descriptionAr: 'صلوات للشفاء من الأمراض والعافية والسلامة',
        descriptionEn: 'Prayers for healing from illnesses, well-being, and safety',
        salawatIds: [],
        keywords: [],
      ),
      
      // 3. Funeral Group
      SalawatGroup(
        id: 3,
        nameAr: 'الجنازة',
        nameEn: 'Funeral',
        icon: Icons.people,
        color: const Color(0xFF9E9E9E),
        descriptionAr: 'صلوات للموتى ولأهل الميت والرحمة والمغفرة',
        descriptionEn: 'Prayers for the deceased, the bereaved family, mercy, and forgiveness',
        salawatIds: [],
        keywords: [],
      ),
      
      // 4. Sustenance Group
      SalawatGroup(
        id: 4,
        nameAr: 'الرزق',
        nameEn: 'Sustenance',
        icon: Icons.attach_money,
        color: const Color(0xFFFF9800),
        descriptionAr: 'صلوات لطلب الرزق الواسع والبركة في المال والعمل',
        descriptionEn: 'Prayers for seeking abundant sustenance and blessings in wealth and work',
        salawatIds: [],
        keywords: [],
      ),
      
      // 5. Protection Group
      SalawatGroup(
        id: 5,
        nameAr: 'الحفظ',
        nameEn: 'Protection',
        icon: Icons.shield,
        color: const Color(0xFF2196F3),
        descriptionAr: 'صلوات للحفظ من الشرور والآفات والأعداء',
        descriptionEn: 'Prayers for protection from evils, calamities, and enemies',
        salawatIds: [],
        keywords: [],
      ),
      
      // 6. Gatherings Group
      SalawatGroup(
        id: 6,
        nameAr: 'المجلس',
        nameEn: 'Gatherings',
        icon: Icons.people,
        color: const Color(0xFF9C27B0),
        descriptionAr: 'صلوات للمجالس والاجتماعات وجمع القلوب',
        descriptionEn: 'Prayers for gatherings, meetings, and uniting hearts',
        salawatIds: [],
        keywords: [],
      ),
      
      // 7. Mawlid Group
      SalawatGroup(
        id: 7,
        nameAr: 'المولد',
        nameEn: 'Mawlid',
        icon: Icons.star,
        color: const Color(0xFFFFC107),
        descriptionAr: 'صلوات في مدح النبي ﷺ وذكر مولد الشريف',
        descriptionEn: 'Prayers praising the Prophet ﷺ and mentioning his noble birth',
        salawatIds: [],
        keywords: [],
      ),
      
      // 8. Dua Group
      SalawatGroup(
        id: 8,
        nameAr: 'الدعاء',
        nameEn: 'Dua',
        icon: Icons.handshake,
        color: const Color(0xFF00BCD4),
        descriptionAr: 'صلوات مستجابة للحوائج وقضاء الديون',
        descriptionEn: 'Responsive prayers for needs and debt relief',
        salawatIds: [],
        keywords: [],
      ),
      
      // 9. Relief Group
      SalawatGroup(
        id: 9,
        nameAr: 'فرج الهم',
        nameEn: 'Relief',
        icon: Icons.emoji_emotions,
        color: const Color(0xFF3F51B5),
        descriptionAr: 'صلوات لتفريج الهموم والكروب وإزالة الغم',
        descriptionEn: 'Prayers for relieving worries, distress, and removing sadness',
        salawatIds: [],
        keywords: [],
      ),
      
      // 10. Charity Group
      SalawatGroup(
        id: 10,
        nameAr: 'الصدقة',
        nameEn: 'Charity',
        icon: Icons.volunteer_activism,
        color: const Color(0xFF8BC34A),
        descriptionAr: 'صلوات لقبول الصدقات والزكوات والإنفاق في سبيل الله',
        descriptionEn: 'Prayers for acceptance of charity, zakat, and spending in Allah\'s way',
        salawatIds: [],
        keywords: [],
      ),
      
      // 11. Travel Group - NEW
      SalawatGroup(
        id: 11,
        nameAr: 'السفر',
        nameEn: 'Travel',
        icon: Icons.flight,
        color: const Color(0xFF00ACC1),
        descriptionAr: 'صلوات للسفر والرحلات والسلامة في الطريق',
        descriptionEn: 'Prayers for travel, journeys, and safety on the road',
        salawatIds: [],
        keywords: [],
      ),
      
      // 12. Success Group - NEW
      SalawatGroup(
        id: 12,
        nameAr: 'النجاح',
        nameEn: 'Success',
        icon: Icons.emoji_events,
        color: const Color(0xFFFFC107),
        descriptionAr: 'صلوات للنجاح في الامتحانات والعمل والحياة',
        descriptionEn: 'Prayers for success in exams, work, and life',
        salawatIds: [],
        keywords: [],
      ),
      
      // 13. Parents Group - NEW
      SalawatGroup(
        id: 13,
        nameAr: 'الوالدين',
        nameEn: 'Parents',
        icon: Icons.family_restroom,
        color: const Color(0xFF795548),
        descriptionAr: 'صلوات لبر الوالدين والرحمة لهم',
        descriptionEn: 'Prayers for honoring parents and mercy upon them',
        salawatIds: [],
        keywords: [],
      ),
      
      // 14. Children Group - NEW
      SalawatGroup(
        id: 14,
        nameAr: 'الأولاد',
        nameEn: 'Children',
        icon: Icons.child_care,
        color: const Color(0xFF4FC3F7),
        descriptionAr: 'صلوات لحماية الأولاد وتربيتهم الصالحة',
        descriptionEn: 'Prayers for children\'s protection and righteous upbringing',
        salawatIds: [],
        keywords: [],
      ),
      
      // 15. Debt Relief Group - NEW
      SalawatGroup(
        id: 15,
        nameAr: 'قضاء الدين',
        nameEn: 'Debt Relief',
        icon: Icons.money_off,
        color: const Color(0xFFF44336),
        descriptionAr: 'صلوات لقضاء الديون وتفريج الكروب المالية',
        descriptionEn: 'Prayers for debt relief and financial ease',
        salawatIds: [],
        keywords: [],
      ),
      
      // 16. Peace of Mind Group - NEW
      SalawatGroup(
        id: 16,
        nameAr: 'راحة البال',
        nameEn: 'Peace of Mind',
        icon: Icons.spa,
        color: const Color(0xFF81C784),
        descriptionAr: 'صلوات لراحة البال والطمأنينة والسكينة',
        descriptionEn: 'Prayers for peace of mind, tranquility, and serenity',
        salawatIds: [],
        keywords: [],
      ),
      
      // 17. Knowledge Group - NEW
      SalawatGroup(
        id: 17,
        nameAr: 'العلم',
        nameEn: 'Knowledge',
        icon: Icons.school,
        color: const Color(0xFF7E57FF),
        descriptionAr: 'صلوات لطلب العلم والفهم والحكمة',
        descriptionEn: 'Prayers for seeking knowledge, understanding, and wisdom',
        salawatIds: [],
        keywords: [],
      ),
      
      // 18. Patience Group - NEW
      SalawatGroup(
        id: 18,
        nameAr: 'الصبر',
        nameEn: 'Patience',
        icon: Icons.hourglass_empty,
        color: const Color(0xFF78909C),
        descriptionAr: 'صلوات للصبر على البلاء والمصائب',
        descriptionEn: 'Prayers for patience during trials and tribulations',
        salawatIds: [],
        keywords: [],
      ),
      
      // 19. Gratitude Group - NEW
      SalawatGroup(
        id: 19,
        nameAr: 'الشكر',
        nameEn: 'Gratitude',
        icon: Icons.thumb_up,
        color: const Color(0xFFFFB74D),
        descriptionAr: 'صلوات للشكر على النعم والفضل',
        descriptionEn: 'Prayers for gratitude for blessings and favors',
        salawatIds: [],
        keywords: [],
      ),
      
      // 20. Forgiveness Group - NEW
      SalawatGroup(
        id: 20,
        nameAr: 'المغفرة',
        nameEn: 'Forgiveness',
        icon: Icons.favorite,
        color: const Color(0xFF9C27B0),
        descriptionAr: 'صلوات لطلب المغفرة والعتق من النار',
        descriptionEn: 'Prayers for seeking forgiveness and salvation from hellfire',
        salawatIds: [],
        keywords: [],
      ),
    ];
  }
}