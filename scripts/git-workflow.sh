#!/bin/bash
# ============================================
# Script de workflow Git pour portfolio Eve-ng
# Version: 2.0
# ============================================

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Fonction principale
main() {
    case "$1" in
        "new-lab")
            create_new_lab
            ;;
        "save")
            save_lab
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# ============================================
# Fonction: Création d'un nouveau lab
# ============================================
create_new_lab() {
    echo -e "\n${BLUE}=== CRÉATION D'UN NOUVEAU LAB ===${NC}\n"
    
    # Demander le nom du lab
    read -p "Nom du lab (sans espaces, utilisez des tirets): " lab_name
    lab_name=$(echo "$lab_name" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
    
    # Vérifier si le lab existe déjà
    if [ -d "$lab_name" ]; then
        error "Le lab '$lab_name' existe déjà!"
        return 1
    fi
    
    # Demander la compétence principale
    read -p "Compétence principale (ex: OSPF, VLAN, BGP): " skill
    
    # Demander la description
    read -p "Description courte: " description
    
    # ============================================
    # CRÉATION DE LA STRUCTURE
    # ============================================
    
    info "Création de la structure pour le lab: $lab_name"
    
    # 1. Créer le répertoire principal du lab
    mkdir -p "$lab_name"
    
    # 2. Créer les sous-répertoires
    mkdir -p "$lab_name/configs"
    mkdir -p "$lab_name/diagrams"
    
    # 3. Créer le fichier README.md avec template
    create_readme_template "$lab_name" "$skill"  "$description"
    
    # 4. Créer un fichier .gitkeep dans les dossiers vides
    touch "$lab_name/configs/.gitkeep"
    touch "$lab_name/diagrams/.gitkeep"
    
    success "Lab '$lab_name' créé avec succès!"
    echo -e "\n${GREEN}Structure créée:${NC}"
    tree "$lab_name" -L 2
    
    echo -e "\n${YELLOW}Prochaines étapes:${NC}"
    echo "1. $lab_name/$lab_name.unl dans Eve-ng"
    echo "2. Configurez votre topologie"
    echo "3. Exportez les configs: ./git-workflow.sh export-configs"
    echo "4. Sauvegardez: ./git-workflow.sh save"
}

# ============================================
# Fonction: Template README.md
# ============================================
create_readme_template() {
    local lab_name="$1"
    local skill="$2"
    local description="$4"
    
    cat > "$lab_name/README.md" << EOF
# Lab: $lab_name

## 📋 Informations générales
- **Compétence**: $skill
- **Date de création**: $(date +%d/%m/%Y)
- **Description**: $description


## 📐 Topologie
![Topologie](diagrams/topology.png)

### Équipements
| Type | Nombre | Modèle | Version |
|------|--------|--------|---------|
| Routeur | 0 | Cisco IOSv | 15.7 |
| Switch | 0 | Cisco IOSvL2 | 15.2 |
| Serveur | 0 | Linux Ubuntu | 20.04 |

## 🔧 Configuration IP

### Routeurs
| Device | Interface | IP/Mask | Description |
|--------|-----------|---------|-------------|

### Switches
| Device | VLAN | Interface | Mode |
|--------|------|-----------|------|

## 📁 Fichiers inclus
- \`$lab_name.unl\` : Topologie Eve-ng
- \`configs/\` : Configurations exportées
- \`diagrams/\` : Diagrammes réseau

## 🚀 Déploiement
1. Copier \`$lab_name.unl\` dans \`/opt/unetlab/labs/\`
2. Importer dans Eve-ng
3. Démarrer les nœuds

## 📝 Notes
- Note 1
- Note 2

---
*Document généré automatiquement le $(date)*
EOF
    
    info "Fichier README.md créé"
}

# ============================================
# Fonction: Sauvegarde Git
# ============================================
save_lab() {
    echo -e "\n${BLUE}=== SAUVEGARDE GIT ===${NC}\n"
    
    # Demander le message de commit
    read -p "Message de commit: " commit_msg
    
    if [ -z "$commit_msg" ]; then
        commit_msg="Update: $(date '+%Y-%m-%d %H:%M:%S')"
    fi
    
    # Ajouter tous les fichiers
    git add .
    
    # Faire le commit
    if git commit -m "$commit_msg"; then
        success "Commit effectué: $commit_msg"
        
        # Demander si on veut pousser sur le remote
        read -p "Voulez-vous pousser sur le remote? (o/N): " push_choice
        if [[ "$push_choice" =~ ^[Oo]$ ]]; then
            git push
            success "Push effectué sur le remote"
        fi
    else
        warning "Aucun changement à commiter"
    fi
}

# ============================================
# Fonction: Aide
# ============================================
show_help() {
    echo -e "${BLUE}=== AIDE: GIT WORKFLOW SCRIPT ===${NC}\n"
    echo "Commandes disponibles:"
    echo ""
    echo "  ${GREEN}new-lab${NC}        - Créer un nouveau lab avec structure complète"
    echo "  ${GREEN}save${NC}           - Sauvegarder les modifications dans Git"
    echo "  ${GREEN}export-configs${NC} - Exporter les configurations (à configurer)"
    echo "  ${GREEN}list-labs${NC}      - Lister tous les labs disponibles"
    echo "  ${GREEN}backup-unl${NC}     - Backup des fichiers .unl"
    echo "  ${GREEN}help${NC}           - Afficher cette aide"
    echo ""
    echo "Exemples:"
    echo "  ./git-workflow.sh new-lab"
    echo "  ./git-workflow.sh save"
    echo ""
    echo "Structure créée par new-lab:"
    echo "  lab-topologies/[nom]/"
    echo "  ├── configs/          # Configurations exportées"
    echo "  ├── diagrams/         # Diagrammes réseau"
    echo "  ├── captures/         # Captures d'écran"
    echo "  ├── documentation/    # Documentation supplémentaire"
    echo "  ├── [nom].unl         # Topologie Eve-ng"
    echo "  ├── README.md         # Documentation du lab"
    echo "  └── validation.sh     # Script de tests"
}

# ============================================
# Point d'entrée principal
# ============================================

# Vérifier qu'on est à la racine du portfolio
if [ ! -d "gitignore" ] && [ ! -d ".git" ]; then
    warning "Ce script doit être exécuté depuis la racine du portfolio!"
    echo "Placez-vous dans ~/eve-ng-portfolio ou /opt/unetlab/portfolio"
    exit 1
fi

# Exécuter la fonction principale
main "$1"
