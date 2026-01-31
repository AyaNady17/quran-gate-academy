/// Centralized cache for teacher and student names to avoid redundant API calls
class NameCache {
  static final Map<String, String> _teacherNameCache = {};
  static final Map<String, String> _studentNameCache = {};

  static String? getTeacherName(String id) => _teacherNameCache[id];
  static String? getStudentName(String id) => _studentNameCache[id];

  static void cacheTeacherName(String id, String name) {
    _teacherNameCache[id] = name;
  }

  static void cacheStudentName(String id, String name) {
    _studentNameCache[id] = name;
  }

  static void cacheTeachers(Map<String, String> teachers) {
    _teacherNameCache.addAll(teachers);
  }

  static void cacheStudents(Map<String, String> students) {
    _studentNameCache.addAll(students);
  }

  static bool hasTeacher(String id) => _teacherNameCache.containsKey(id);
  static bool hasStudent(String id) => _studentNameCache.containsKey(id);

  static void clear() {
    _teacherNameCache.clear();
    _studentNameCache.clear();
  }
}
