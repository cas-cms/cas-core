//= require cas/lib/sort

describe('sortNumber', function() {
  it("returns 1, 2, 3, 4, 5 in order", function() {
    expect(["5", 2, "3", 1, "4"].sort(sortNumber)).toEqual([1, 2, "3", "4", "5"]);
  });
});

describe('sortFilenames', function() {
  describe("both files with numbers", function() {
    describe("[(151).jpg, (64).jpg] => [(64).jpg, (151).jpg]", function() {
      var input = ["(151).jpg", "(64).jpg"].sort(sortFilenames).join(', ');
      var expected = ["(64).jpg", "(151).jpg"].join(', ');

      it("returns '(64).jpg', (151).jpg", function() {
        expect(input).toEqual(expected);
      });
    });

    describe("[(2).jpg, (151).jpg] => [(2).jpg, (151).jpg]", function() {
      var input = ["(151).jpg", "(2).jpg"].sort(sortFilenames).join(', ');;
      var expected = ["(2).jpg", "(151).jpg"].join(', ');

      it("returns '(2).jpg', (151).jpg", function() {
        expect(input).toEqual(expected);
      });
    });
  });

  describe("one file with numbers and the other not", function() {
    describe("[abc.jpg, 64.jpg] => [64.jpg, abc.jpg]", function() {
      var input = ["abc.jpg", "64.jpg"].sort(sortFilenames).join(', ');
      var expected = ["64.jpg", "abc.jpg"].join(', ');

      it("returns ['64.jpg', 'abc.jpg']", function() {
        expect(input).toEqual(expected);
      });
    });
  });
});
