# Fill in build related constants
const_config = configuration_data()
const_config.set_quoted('PROJECT_NAME', meson.project_name())
const_config.set_quoted('VERSION', meson.project_version())
const_config.set_quoted('RESOURCE_BASE', meson.project_name().replace('.', '/'))
const_config.set_quoted('LOCALEDIR', get_option('prefix') / get_option('localedir'))

const_src = configure_file(
    input: 'Consts.vala.in',
    output: 'Consts.vala',
    configuration: const_config,
)

# List all source files
common_sources = files(
    'Application.vala',
    'MainWindow.vala',
    'Models/Converters/AmountConverter.vala',
    'Models/Converters/CompositeAmountConverter.vala',
    'Models/Converters/IdentityAmountConverter.vala',
    'Models/Converters/MultiplierBasedAmountConverter.vala',
    'Models/Converters/PreferenceBasedAmountConverter.vala',
    'Models/Converters/ReferentUnitRationBasedAmountConverter.vala',
    'Models/Amount.vala',
    'Models/AmountParser.vala',
    'Models/Ingredient.vala',
    'Models/IngredientGroup.vala',
    'Models/ParsingError.vala',
    'Models/Recipe.vala',
    'Models/RecipeParser.vala',
    'Models/Tag.vala',
    'Models/Unit.vala',
    'Models/Units.vala',
    'Services/ConverterService.vala',
    'Services/DatabaseService.vala',
    'Services/RecipesService.vala',
    'Services/ServiceError.vala',
    'Views/LibraryView.vala',
    'Views/RecipeView.vala',
    'Widgets/EditableIngredient.vala',
    'Widgets/EditableIngredientGroups.vala',
    'Widgets/EditableLabel.vala',
    'Widgets/RecipeHeader.vala',
    'Widgets/TagPill.vala',
    'Widgets/TagsRow.vala',
)
common_sources += const_src

sources = common_sources + files('main.vala')
