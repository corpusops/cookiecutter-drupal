Le workflow de développement
==============================

Lorsque que je souhaite développer une nouvelle fonctionnalité,

.. note:: Sur le board Gitlab, je passe le ticket dans la colonne `Todo`

.. code-block:: sh

    # je mets sur master
    git checkout master

    # je mets à jour le code
    git pull -r

    # j'upgrade mon build
    ./control.sh userexec bin/composerinstall

    # je mets à jour la configuration & la base de données de Drupal
    ./control.sh userexec bin/post_update.sh

Ensuite je créée une nouvelle branche depuis master en commenceant par `dev-xxx-`:

.. code-block:: sh

    git checkout -b dev-121-ma-fonctionnalite

A chaque fois que je commite, si j'ai fais des modifications dans la configuration de Drupal:

.. code-block:: sh

    ./control.sh userexec bin/drush cex

.. warning:: Je ne commite **que** les modifications dans les fichiers de configuration qui concernent ma fonctionnanlité et je checkout les autres.

.. note:: Je commence le nom de mon commit par le numéro de mon ticket comme ça : `issue #121 - `

Lorsque le développement de la fonctionnanlité est fini, je pousse ma branche et je fais une merge-request sur gitlab.
