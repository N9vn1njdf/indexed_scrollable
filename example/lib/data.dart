import 'dart:math';

const _text = """
At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident, similique sunt in culpa qui officia deserunt mollitia animi, id est laborum et dolorum fuga.
Nam libero tempore, cum soluta nobis est eligendi optio cumque nihil impedit quo minus id quod maxime placeat facere possimus, omnis voluptas assumenda est, omnis dolor repellendus.
Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat.""";

class Data {
  /// Возращает массив строк случайной длины
  static List<String> get(int count) {
    final rand = new Random();
    List<String> arr = [];

    for (var i = 0; i < count; i++) {
      // Вырываем кусок текста в случайном диапазоне
      var start = rand.nextInt((_text.length / 2).round());
      var end = start + rand.nextInt(_text.length - start - 20) + 20;

      arr.add(_text.substring(start, end));
    }

    return arr;
  }
}
