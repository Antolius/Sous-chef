/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2023 Josip Antoliš <josip.antolis@protonmail.com>
*/

namespace Souschef.ParsingTests {

    public void add_funcs () {
        Test.add_func ("/Parsing/recipe", test_recipe);
    }

    void test_recipe () {
        var given_recipe = """# Title

The description describes this recipe. It is delicious!

It can have multiple lines an may even include pictures.

<img src="../logo/recipemd-mark.svg" />

*vegetarian, vegan, not a real recipe*

**5 cups, 20 ml, 5,5 Tassen**

---

- *5* ungrouped ingredient
- *5.2 ml* grouped ingredient

## Group 1

- *1* [link ingredient](./ingredients.md)
- unit is optional

### Subgroup 1.1

- *1.25 ml* ingredient

## Group 2

- text isn't optional
- *hey* amount is valid without factor

---

Instructions are very instructive.""";
        var parser = new RecipeParser (0, given_recipe);
        var actual = parser.parse ();
        assert_nonnull (actual);

        assert_cmpstr (actual.title, CompareOperator.EQ, "Title");

        assert_cmpstr (actual.description, CompareOperator.EQ, """The description describes this recipe. It is delicious!

It can have multiple lines an may even include pictures.

<img src="../logo/recipemd-mark.svg" />""");

        var tags = actual.tags;
        assert_nonnull (tags);
        assert_cmpint (tags.size, CompareOperator.EQ, 3);
        assert_cmpstr (tags.get(0), CompareOperator.EQ, "vegetarian");
        assert_cmpstr (tags.get(1), CompareOperator.EQ, "vegan");
        assert_cmpstr (tags.get(2), CompareOperator.EQ, "not a real recipe");

        var yields = actual.yields;
        assert_nonnull (yields);
        assert_cmpint (yields.size, CompareOperator.EQ, 3);
        assert_cmpfloat (yields[0].value, CompareOperator.EQ, 5.0);
        assert_nonnull (yields[0].unit);
        assert_cmpstr (yields[0].unit.name, CompareOperator.EQ, "cups");
        assert_cmpfloat (yields[1].value, CompareOperator.EQ, 20.0);
        assert_nonnull (yields[1].unit);
        assert_cmpstr (yields[1].unit.name, CompareOperator.EQ, "ml");
        assert_cmpfloat (yields[1].value, CompareOperator.EQ, 20.0);
        assert_nonnull (yields[1].unit);
        assert_cmpstr (yields[1].unit.name, CompareOperator.EQ, "ml");
        assert_cmpfloat (yields[2].value, CompareOperator.EQ, 5.5);
        assert_nonnull (yields[2].unit);
        assert_cmpstr (yields[2].unit.name, CompareOperator.EQ, "Tassen");
    }

}
