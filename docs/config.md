# Configurations: `cas.config.yml`

Cas is managed with a YAML file. It lives in `config/cas.config.yml` and
includes what sections exist, what contents, what are the default users, and the
associations among contents.

**Why a YAML for configuration?**

Config lives in a YAML file with the intent of keeping usage of Cas as
descriptive as possible. The alternatives, in which you write code, tend to be
more imperative. We'd like Cas to be as automatic as possible, so we went with
this approach for v1.

**What does the YAML configure?**

In summary, you will specific what structure of content your website will have,
and Cas will autogenerate records for you based on that. You will be able to set
what fields should appear in forms, what columns should appear in tables.

**What should I know before configuring?**

Cas has three primary Rails models/tables around which everything orbits.

- **Site:** you can manage multiple websites with Cas. For most cases, you'll
  likely have only one.
- **Section:** this belongs to a Site and is a segment of your site/app. For
  example, a section can be _news_, _pages_ or _recipes_.
- **Content:** this is a record of content, such as news, a post, a recipe.

The YAML file will define each site, their sections, and the structure of
contents, like what fields to show in forms and lists.

For fine-grained details, we recommend checking `Cas::Site`, `Cas::Section`,
`Cas::Content` because they're pure Rails models.

**Usage**

Here's a sample `cas.config.yml`:

```yaml
sites:
  mama_recipes:
    name: Mama Recipes

    # [optional]
    #
    # Specifying domains is useful in case you have multiple websites. In that
    # case, the admin will automatically switch what content it is showing, but
    # you can still admin other website's content.
    domains:
      - mamarecipes.com


    # Config: global configuration across all sites
    config:
      # [optional]
      #
      # This is the list of users (Cas::Users) that will be automatically
      # created during installation
      initial_admins:
        - friend@example.com
        - user@example.com

      # Superadmins can create other admins and users. Define which emails or logins
      # you want to set as superadmin.
      superadmins:
        - user@example.com

    # Sections [required]
    #
    # These are all the sections the website is going to have. You can use this
    # store contents (e.g news, recipes) and also lists in general (e.g
    # vegetables)
    sections:
      recipes:          # slug, unique section identifier
        name: "Recipes" # human name
        type: content   # content || survey (alpha)

        # [optional]
        #
        # Content Index: fields that should appear in #index for this section in
        # the admin. The  index has a table of contents, and these are going to
        # be the columns
        list_fields:
          - title
          - category

        # [required, at least one field]
        #
        # Form fields: there are predefined form fields. In other words, `title`
        # is reserved and you can't have something adhoc like `tomato`. These
        # will match to the columns in Cas::Content.
        fields:
          - title    # a simple text input
          - category # a dropdown for categories
          - tags     # a field for tags and labels, with autocomplete
          - summary  # a textarea
          - text     # textarea
          - images   # a gallery for uploading images
          - files    # same as images, but for PDFs and docs
          - date     # in case you want to set some specific date

          # This is an association to be show and editable in the form. It has
          # to match a `has_many` entry.
          - ingredients:
            label: "Ingredients"

        has_many:
          - ingredients # this has to match a section name/slug

      # Another section
      ingredients:
        name: "Ingredients"
        type: content

        # By having only `title`, no other input will be shown in the form
        fields:
          - title
```


**Is my homepage also configured by `cas.config.yml`?**

No. You should have your own Rails code for your homepage and public pages. You
will, however, use `Cas::Content` to list content, but you are responsible
ultimately for what is shown on the screen.

The `cas.config.yml` only manages what happens in `/admin`.
