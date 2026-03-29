import 'package:flutter/material.dart';

class SalawatGroup {
  final int id;
  final String nameAr;
  final String nameEn;
  final IconData icon;
  final Color color;
  final String descriptionAr;
  final String descriptionEn;
  final String correspondingBab; // Which bab in the book
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
    required this.correspondingBab,
    required this.salawatIds,
    required this.keywords,
  });
}

class GroupsData {
  static List<SalawatGroup> getGroups() {
    return [
      // ==================== SECTION 1: VIRTUES OF PRAYING UPON THE PROPHET ====================
      // Based on: باب في فضل الصلاة على النبي ﷺ
      
      // 1. Virtues of Salawat
      SalawatGroup(
        id: 1,
        nameAr: 'فضائل الصلاة على النبي',
        nameEn: 'Virtues of Salawat',
        icon: Icons.star,
        color: const Color(0xFFFFD700),
        descriptionAr: 'صلوات تبرز فضل الصلاة على النبي ﷺ وثوابها العظيم',
        descriptionEn: 'Prayers highlighting the virtues and great rewards of sending salawat upon the Prophet',
        correspondingBab: 'باب في فضل الصلاة على النبي',
        salawatIds: [],
        keywords: [],
      ),
      
      // 2. Blessings & Rewards
      SalawatGroup(
        id: 2,
        nameAr: 'البركات والثواب',
        nameEn: 'Blessings & Rewards',
        icon: Icons.card_giftcard,
        color: const Color(0xFF4CAF50),
        descriptionAr: 'صلوات تجلب البركات والحسنات والمضاعفة من الله',
        descriptionEn: 'Prayers that bring blessings, good deeds, and multiplication from Allah',
        correspondingBab: 'باب في فضل الصلاة على النبي',
        salawatIds: [],
        keywords: [],
      ),
      
      // ==================== SECTION 2: PROPHET'S BEAUTY AND CHARACTER ====================
      // Based on: باب في وصف خلقه وجماله
      
      // 3. Physical Beauty of the Prophet
      SalawatGroup(
        id: 3,
        nameAr: 'جمال النبي ﷺ',
        nameEn: 'Prophet\'s Beauty',
        icon: Icons.wb_sunny,
        color: const Color(0xFFFF9800),
        descriptionAr: 'صلوات تصف جمال النبي ﷺ الخِلقي والخُلُقي',
        descriptionEn: 'Prayers describing the physical and moral beauty of the Prophet',
        correspondingBab: 'باب في وصف خلقه وجماله',
        salawatIds: [],
        keywords: [],
      ),
      
      // 4. Noble Character
      SalawatGroup(
        id: 4,
        nameAr: 'أخلاق النبي',
        nameEn: 'Prophet\'s Character',
        icon: Icons.psychology,
        color: const Color(0xFF2196F3),
        descriptionAr: 'صلوات تصف أخلاق النبي ﷺ الكريمة وشمائله العظيمة',
        descriptionEn: 'Prayers describing the noble character and great manners of the Prophet',
        correspondingBab: 'باب في وصف خلقه وجماله',
        salawatIds: [],
        keywords: [],
      ),
      
      // ==================== SECTION 3: MIRACLES AND SIGNS ====================
      // Based on: باب في معرفة آياته ومعجزاته
      
      // 5. Miracles of the Prophet
      SalawatGroup(
        id: 5,
        nameAr: 'معجزات النبي',
        nameEn: 'Prophet\'s Miracles',
        icon: Icons.auto_awesome,
        color: const Color(0xFF9C27B0),
        descriptionAr: 'صلوات تذكر معجزات النبي ﷺ وآياته الباهرات',
        descriptionEn: 'Prayers mentioning the miracles and astonishing signs of the Prophet',
        correspondingBab: 'باب في معرفة آياته ومعجزاته',
        salawatIds: [],
        keywords: [],
      ),
      
      // 6. Isra and Miraj
      SalawatGroup(
        id: 6,
        nameAr: 'الإسراء والمعراج',
        nameEn: 'Isra & Miraj',
        icon: Icons.flight_takeoff,
        color: const Color(0xFF00BCD4),
        descriptionAr: 'صلوات خاصة بليلة الإسراء والمعراج',
        descriptionEn: 'Special prayers for the night of Isra and Miraj',
        correspondingBab: 'باب في معرفة آياته ومعجزاته',
        salawatIds: [],
        keywords: [],
      ),
      
      // ==================== SECTION 4: PROPHET'S NAMES AND TITLES ====================
      // Based on: باب في ذكر بعض أسمائه الشريفة
      
      // 7. Names of the Prophet
      SalawatGroup(
        id: 7,
        nameAr: 'أسماء النبي',
        nameEn: 'Prophet\'s Names',
        icon: Icons.text_fields,
        color: const Color(0xFF607D8B),
        descriptionAr: 'صلوات تشتمل على أسماء النبي ﷺ الحسنى',
        descriptionEn: 'Prayers containing the beautiful names of the Prophet',
        correspondingBab: 'باب في ذكر بعض أسمائه الشريفة',
        salawatIds: [],
        keywords: [],
      ),
      
      // 8. Titles & Epithets
      SalawatGroup(
        id: 8,
        nameAr: 'ألقاب النبي',
        nameEn: 'Prophet\'s Titles',
        icon: Icons.workspace_premium,
        color: const Color(0xFFFF5722),
        descriptionAr: 'صلوات بألقاب النبي ﷺ الكريمة',
        descriptionEn: 'Prayers with the noble titles of the Prophet',
        correspondingBab: 'باب في ذكر بعض أسمائه الشريفة',
        salawatIds: [],
        keywords: [],
      ),
      
      // ==================== SECTION 5: PROPHET'S SUPERIORITY ====================
      // Based on: باب في ذكر فضله على الأنبياء
      
      // 9. Superiority over Prophets
      SalawatGroup(
        id: 9,
        nameAr: 'فضل النبي على الأنبياء',
        nameEn: 'Superiority over Prophets',
        icon: Icons.leaderboard,
        color: const Color(0xFF795548),
        descriptionAr: 'صلوات تبين فضل النبي ﷺ على سائر الأنبياء',
        descriptionEn: 'Prayers showing the Prophet\'s superiority over all other prophets',
        correspondingBab: 'باب في ذكر فضله على الأنبياء',
        salawatIds: [],
        keywords: [],
      ),
      
      // 10. Intercession (Shafa'ah)
      SalawatGroup(
        id: 10,
        nameAr: 'الشفاعة',
        nameEn: 'Intercession',
        icon: Icons.handshake,
        color: const Color(0xFFE91E63),
        descriptionAr: 'صلوات لطلب شفاعة النبي ﷺ يوم القيامة',
        descriptionEn: 'Prayers seeking the Prophet\'s intercession on Judgment Day',
        correspondingBab: 'باب في ذكر فضله على الأنبياء',
        salawatIds: [],
        keywords: [],
      ),
      
      // ==================== SECTION 6: RIGHTS OF THE PROPHET ====================
      // Based on: باب في ذكر حقه على أمته
      
      // 11. Love of the Prophet
      SalawatGroup(
        id: 11,
        nameAr: 'محبة النبي',
        nameEn: 'Love of the Prophet',
        icon: Icons.favorite,
        color: const Color(0xFFF44336),
        descriptionAr: 'صلوات تعبر عن محبة النبي ﷺ',
        descriptionEn: 'Prayers expressing love for the Prophet',
        correspondingBab: 'باب في ذكر حقه على أمته',
        salawatIds: [],
        keywords: [],
      ),
      
      // 12. Following the Prophet
      SalawatGroup(
        id: 12,
        nameAr: 'اتباع السنة',
        nameEn: 'Following the Sunnah',
        icon: Icons.timeline,
        color: const Color(0xFF8BC34A),
        descriptionAr: 'صلوات للثبات على اتباع سنة النبي ﷺ',
        descriptionEn: 'Prayers for steadfastness in following the Prophet\'s Sunnah',
        correspondingBab: 'باب في ذكر حقه على أمته',
        salawatIds: [],
        keywords: [],
      ),
      
      // ==================== SECTION 7: FAMILY AND COMPANIONS ====================
      // Based on: باب في ذكر بعض مناقب آله وأصحابه
      
      // 13. Ahl al-Bayt (Family)
      SalawatGroup(
        id: 13,
        nameAr: 'آل البيت',
        nameEn: 'Ahl al-Bayt',
        icon: Icons.family_restroom,
        color: const Color(0xFF9C27B0),
        descriptionAr: 'صلوات في مناقب آل بيت النبي ﷺ',
        descriptionEn: 'Prayers on the virtues of the Prophet\'s family',
        correspondingBab: 'باب في ذكر بعض مناقب آله وأصحابه',
        salawatIds: [],
        keywords: [],
      ),
      
      // 14. Companions (Sahabah)
      SalawatGroup(
        id: 14,
        nameAr: 'الصحابة',
        nameEn: 'Companions',
        icon: Icons.group,
        color: const Color(0xFF3F51B5),
        descriptionAr: 'صلوات في مناقب الصحابة الكرام',
        descriptionEn: 'Prayers on the virtues of the noble companions',
        correspondingBab: 'باب في ذكر بعض مناقب آله وأصحابه',
        salawatIds: [],
        keywords: [],
      ),
      
      // ==================== SECTION 8: SUPPLICATION AND FORGIVENESS ====================
      // Based on: باب في الاستغفار والدعاء
      
      // 15. Seeking Forgiveness
      SalawatGroup(
        id: 15,
        nameAr: 'الاستغفار',
        nameEn: 'Seeking Forgiveness',
        icon: Icons.cleaning_services,
        color: const Color(0xFF00BCD4),
        descriptionAr: 'صلوات للاستغفار وطلب المغفرة من الله',
        descriptionEn: 'Prayers for seeking forgiveness from Allah',
        correspondingBab: 'باب في الاستغفار والدعاء',
        salawatIds: [],
        keywords: [],
      ),
      
      // 16. Supplication (Dua)
      SalawatGroup(
        id: 16,
        nameAr: 'الدعاء',
        nameEn: 'Supplication',
        icon: Icons.handshake,
        color: const Color(0xFF4CAF50),
        descriptionAr: 'صلوات وأدعية لقضاء الحوائج',
        descriptionEn: 'Prayers and supplications for fulfilling needs',
        correspondingBab: 'باب في الاستغفار والدعاء',
        salawatIds: [],
        keywords: [],
      ),
      
      // ==================== EXTENDED GROUPS (From Multiple Babs) ====================
      
      // 17. Healing & Protection (From Various Babs)
      SalawatGroup(
        id: 17,
        nameAr: 'الشفاء والحفظ',
        nameEn: 'Healing & Protection',
        icon: Icons.health_and_safety,
        color: const Color(0xFF4CAF50),
        descriptionAr: 'صلوات للشفاء من الأمراض والحفظ من الشرور',
        descriptionEn: 'Prayers for healing from illnesses and protection from evils',
        correspondingBab: 'من أبواب متعددة',
        salawatIds: [],
        keywords: [],
      ),
      
      // 18. Sustenance & Blessings (From Various Babs)
      SalawatGroup(
        id: 18,
        nameAr: 'الرزق والبركة',
        nameEn: 'Sustenance & Blessings',
        icon: Icons.agriculture,
        color: const Color(0xFFFF9800),
        descriptionAr: 'صلوات لجلب الرزق والبركة في المال والعمل',
        descriptionEn: 'Prayers for bringing sustenance and blessings in wealth and work',
        correspondingBab: 'من أبواب متعددة',
        salawatIds: [],
        keywords: [],
      ),
      
      // 19. Relief from Distress (From Various Babs)
      SalawatGroup(
        id: 19,
        nameAr: 'فرج الكروب',
        nameEn: 'Relief from Distress',
        icon: Icons.psychology_alt,
        color: const Color(0xFF3F51B5),
        descriptionAr: 'صلوات لتفريج الهموم والكروب',
        descriptionEn: 'Prayers for relieving worries and distress',
        correspondingBab: 'من أبواب متعددة',
        salawatIds: [],
        keywords: [],
      ),
      
      // 20. Mawlid & Praising the Prophet (From Multiple Babs)
      SalawatGroup(
        id: 20,
        nameAr: 'المولد والمدائح',
        nameEn: 'Mawlid & Praises',
        icon: Icons.celebration,
        color: const Color(0xFFFFD700),
        descriptionAr: 'صلوات في مدح النبي ﷺ وذكر مولده الشريف',
        descriptionEn: 'Prayers praising the Prophet ﷺ and mentioning his noble birth',
        correspondingBab: 'من عدة أبواب',
        salawatIds: [],
        keywords: [],
      ),
    ];
  }
}