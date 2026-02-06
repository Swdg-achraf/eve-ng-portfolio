#!/bin/bash
# Script pour faciliter le versionnement des labs

echo "=== Workflow Git pour Lab Réseau ==="

case "$1" in
    "new-lab")
        echo "Création d'un nouveau lab..."
        read -p "Nom du lab : " lab_name
        read -p "Compétence principale : " skill
        
        mkdir -p "lab-topologies/$lab_name"
        mkdir -p "configs/$lab_name"
        mkdir -p "documentation/diagrams/$lab_name"
        
        # Template de README pour le lab
        cat > "lab-topologies/$lab_name/README.md" << EOF
# Lab: $lab_name

## Compétence: $skill
Date: $(date +%Y-%m-%d)

## Topologie
![Topologie](diagrams/$lab_name/topology.png)

## Objectifs
- [ ] Objectif 1
- [ ] Objectif 2

## Prérequis
- ...

## Procédure
1. ...

## Validation
\`\`\`bash
# Commandes de vérification
\`\`\`

## Notes
EOF
        
        echo "Lab '$lab_name' créé avec succès!"
        ;;
        
    "save")
        echo "Sauvegarde du lab en cours..."
        git add .
        read -p "Message de commit : " commit_msg
        git commit -m "$commit_msg"
        echo "Commit effectué!"
        ;;
        
    "export-configs")
        echo "Export des configurations..."
        # À adapter selon votre méthode d'export
        python3 scripts/export-configs.py
        ;;
        
    *)
        echo "Usage: $0 {new-lab|save|export-configs}"
        ;;
esac