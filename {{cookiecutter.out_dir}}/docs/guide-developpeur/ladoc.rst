.. _developpeur-front:

Guide de génération de la doc & cycle de release
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

Introduction
============
Les docs sont générées à l'aide de **sphinx**.

Générer les assets
==================

En mode développement
---------------------

C'est aussi simple que:

.. code-block:: sh

   # Aller dans le répertoire du projet
   cd /path/to/projet

   # Il faut être dans le répertoire de l'application
   ./control.sh make_docs

.. note::

   Vous n'aurez jamais besoin de supprimer le répertoire où c'est généré à
   la main, le script est configuré pour et le fait automatiquement.


Versionner la doc
=====================

**Les assets distribuables générés sont versionnés avec le code source de**
**l'application**.


Pour exporter la doc sur git
----------------------------

.. code-block:: sh

   cd /path/to/projet
   ./control.sh make_docs
   git add -f app/var/docs/*/*
   git commit -m "Generate docs" app/var/docs/

