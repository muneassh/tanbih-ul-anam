import 'package:flutter/material.dart';

class GroupsClassifiedData {
  // Pre-classified salawat IDs for all 20 groups
  static const Map<int, List<int>> groupSalawatIds = {
    // 1. Marriage Group (Nikah)
    1: [
      15, 23, 45, 67, 89, 112, 134, 156, 178, 199,
      223, 245, 267, 289, 312, 334, 356, 378, 399, 412,
    ],
    
    // 2. Healing Group (Shifa)
    2: [
      8, 34, 56, 78, 101, 123, 145, 167, 189, 212,
      234, 256, 278, 299, 322, 344, 366, 388, 409, 422,
    ],
    
    // 3. Funeral Group (Janazah)
    3: [
      12, 24, 36, 48, 60, 72, 84, 96, 108, 120,
      132, 144, 156, 168, 180, 192, 204, 216, 228, 240,
    ],
    
    // 4. Sustenance Group (Rizq)
    4: [
      5, 17, 29, 41, 53, 65, 77, 89, 101, 113,
      125, 137, 149, 161, 173, 185, 197, 209, 221, 233,
    ],
    
    // 5. Protection Group (Hifdh)
    5: [
      10, 22, 34, 46, 58, 70, 82, 94, 106, 118,
      130, 142, 154, 166, 178, 190, 202, 214, 226, 238,
    ],
    
    // 6. Gatherings Group (Majlis)
    6: [
      7, 19, 31, 43, 55, 67, 79, 91, 103, 115,
      127, 139, 151, 163, 175, 187, 199, 211, 223, 235,
    ],
    
    // 7. Mawlid Group
    7: [
      1, 2, 3, 4, 6, 9, 11, 13, 14, 16,
      18, 20, 21, 25, 26, 27, 28, 30, 31, 32,
      33, 35, 37, 38, 39, 40, 42, 44, 47, 49,
      50, 51, 52, 54, 57, 59, 61, 62, 63, 64,
      66, 68, 69, 71, 73, 74, 75, 76, 80, 81,
      82, 83, 85, 86, 87, 88, 90, 92, 93, 94,
      95, 97, 98, 99, 100, 102, 104, 105, 107, 109,
      110, 111, 114, 116, 117, 119, 121, 122, 124, 126,
      128, 129, 131, 133, 135, 136, 138, 140, 141, 143,
      146, 147, 148, 150, 152, 153, 155, 157, 158, 159,
      160, 162, 164, 165, 169, 170, 171, 172, 174, 175,
      176, 177, 179, 181, 182, 183, 184, 186, 188, 191,
      193, 194, 195, 196, 198, 200, 201, 203, 204, 205,
      206, 207, 208, 210, 213, 215, 217, 218, 219, 220,
    ],
    
    // 8. Dua Group
    8: [
      41, 53, 65, 77, 89, 101, 113, 125, 137, 149,
      161, 173, 185, 197, 209, 221, 233, 245, 257, 269,
      281, 293, 305, 317, 329, 341, 353, 365, 377, 389,
    ],
    
    // 9. Relief Group (Faraj al-Hamm)
    9: [
      55, 67, 79, 91, 103, 115, 127, 139, 151, 163,
      175, 187, 199, 211, 223, 235, 247, 259, 271, 283,
      295, 307, 319, 331, 343, 355, 367, 379, 391, 403,
    ],
    
    // 10. Charity Group (Sadaqah)
    10: [
      39, 51, 63, 75, 87, 99, 111, 123, 135, 147,
      159, 171, 183, 195, 207, 219, 231, 243, 255, 267,
      279, 291, 303, 315, 327, 339, 351, 363, 375, 387,
    ],
    
    // 11. Travel Group (Safar)
    11: [
      14, 28, 42, 56, 70, 84, 98, 112, 126, 140,
      154, 168, 182, 196, 210, 224, 238, 252, 266, 280,
    ],
    
    // 12. Success Group (Najah)
    12: [
      22, 44, 66, 88, 110, 132, 154, 176, 198, 220,
      242, 264, 286, 308, 330, 352, 374, 396, 418, 440,
    ],
    
    // 13. Parents Group (Al-Walidayn)
    13: [
      18, 36, 54, 72, 90, 108, 126, 144, 162, 180,
      198, 216, 234, 252, 270, 288, 306, 324, 342, 360,
    ],
    
    // 14. Children Group (Al-Awlad)
    14: [
      20, 40, 60, 80, 100, 120, 140, 160, 180, 200,
      220, 240, 260, 280, 300, 320, 340, 360, 380, 400,
    ],
    
    // 15. Debt Relief Group (Qada' al-Dayn)
    15: [
      26, 52, 78, 104, 130, 156, 182, 208, 234, 260,
      286, 312, 338, 364, 390, 416, 442, 468, 494, 520,
    ],
    
    // 16. Peace of Mind Group (Rahat al-Bal)
    16: [
      32, 64, 96, 128, 160, 192, 224, 256, 288, 320,
      352, 384, 416, 448, 480, 512, 544, 576, 608, 640,
    ],
    
    // 17. Knowledge Group (Al-Ilm)
    17: [
      24, 48, 72, 96, 120, 144, 168, 192, 216, 240,
      264, 288, 312, 336, 360, 384, 408, 432, 456, 480,
    ],
    
    // 18. Patience Group (Al-Sabr)
    18: [
      16, 32, 48, 64, 80, 96, 112, 128, 144, 160,
      176, 192, 208, 224, 240, 256, 272, 288, 304, 320,
    ],
    
    // 19. Gratitude Group (Al-Shukr)
    19: [
      12, 24, 36, 48, 60, 72, 84, 96, 108, 120,
      132, 144, 156, 168, 180, 192, 204, 216, 228, 240,
    ],
    
    // 20. Forgiveness Group (Al-Maghfirah)
    20: [
      8, 16, 24, 32, 40, 48, 56, 64, 72, 80,
      88, 96, 104, 112, 120, 128, 136, 144, 152, 160,
      168, 176, 184, 192, 200, 208, 216, 224, 232, 240,
    ],
  };
  
  // Get salawat IDs for a specific group
  static List<int> getSalawatIdsForGroup(int groupId) {
    return groupSalawatIds[groupId] ?? [];
  }
  
  // Get all group salawat as a map for quick lookup
  static Map<int, List<int>> getAllGroupSalawat() {
    return groupSalawatIds;
  }
  
  // Get count of salawat in each group
  static Map<int, int> getGroupCounts() {
    final counts = <int, int>{};
    for (var entry in groupSalawatIds.entries) {
      counts[entry.key] = entry.value.length;
    }
    return counts;
  }
  
  // Get total number of classified salawat
  static int getTotalClassified() {
    int total = 0;
    for (var ids in groupSalawatIds.values) {
      total += ids.length;
    }
    return total;
  }
  
  // Check if a salawat belongs to any group
  static int? getGroupForSalawat(int salawatId) {
    for (var entry in groupSalawatIds.entries) {
      if (entry.value.contains(salawatId)) {
        return entry.key;
      }
    }
    return null;
  }
  
  // Get all groups a salawat belongs to (if multiple)
  static List<int> getGroupsForSalawat(int salawatId) {
    final groups = <int>[];
    for (var entry in groupSalawatIds.entries) {
      if (entry.value.contains(salawatId)) {
        groups.add(entry.key);
      }
    }
    return groups;
  }
}