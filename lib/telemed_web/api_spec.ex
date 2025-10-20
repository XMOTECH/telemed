defmodule TelemedWeb.ApiSpec do
  @moduledoc """
  Spécification OpenAPI 3.0 complète pour l'API Telemed.

  Accessible via:
  - Swagger UI: http://localhost:4001/swaggerui
  - JSON brut: http://localhost:4001/api/openapi
  """

  alias OpenApiSpex.{Info, OpenApi, Server, Components, SecurityScheme, Contact, License}
  alias TelemedWeb.Router

  @behaviour OpenApi

  @impl OpenApi
  def spec do
    %OpenApi{
      info: %Info{
        title: "🏥 Telemed API - Télémédecine & DME",
        description: """
        # API REST Complète - Plateforme de Télémédecine

        Bienvenue dans l'API Telemed ! Cette API permet de gérer une plateforme complète de télémédecine avec :

        ## 🎯 Fonctionnalités Principales

        ### 🔐 Authentification & Sécurité
        - Inscription/Connexion utilisateurs (Patient, Doctor, Admin)
        - JWT tokens (access + refresh)
        - RBAC (Role-Based Access Control)
        - Sessions sécurisées

        ### 📋 Dossiers Médicaux Électroniques (DME)
        - Structure SOAP (Subjective/Objective/Assessment/Plan)
        - Catégorisation et tags
        - Historique complet
        - Permissions granulaires par rôle

        ### 📅 Gestion des Rendez-vous
        - Création et planification
        - Confirmation/Annulation
        - Notifications automatiques
        - Statuts multiples (pending, confirmed, cancelled, completed)

        ### 🔔 Notifications Temps Réel
        - Alertes rendez-vous
        - Confirmations médecin
        - Résultats disponibles
        - Marquage lu/non lu

        ### 📎 Documents Médicaux
        - Upload fichiers (ordonnances, résultats, images)
        - Download sécurisé
        - Types multiples (prescription, lab_result, scan, etc.)
        - Preview images

        ## 🔑 Authentification

        ### Workflow Standard

        ```
        1. POST /api/v1/auth/register
           → Créer un compte (patient/doctor)

        2. POST /api/v1/auth/login
           → Obtenir access_token & refresh_token

        3. Utiliser le token dans toutes les requêtes:
           Authorization: Bearer {access_token}

        4. POST /api/v1/auth/refresh (après 1h)
           → Renouveler le token avec refresh_token
        ```

        ### Tester avec Swagger UI

        1. Cliquer sur "Authorize" 🔒 (en haut à droite)
        2. Entrer: `Bearer {votre_access_token}`
        3. Cliquer "Authorize"
        4. Tous les endpoints protégés sont maintenant accessibles !

        ## 📚 Exemples Rapides

        ### Créer un compte patient
        ```bash
        curl -X POST http://localhost:4001/api/v1/auth/register \\
          -H "Content-Type: application/json" \\
          -d '{
            "user": {
              "email": "patient@test.com",
              "password": "MotDePasse123!",
              "role": "patient",
              "first_name": "Jean",
              "last_name": "Dupont"
            }
          }'
        ```

        ### Se connecter
        ```bash
        curl -X POST http://localhost:4001/api/v1/auth/login \\
          -H "Content-Type: application/json" \\
          -d '{
            "email": "patient@test.com",
            "password": "MotDePasse123!"
          }'
        ```

        ### Créer un rendez-vous
        ```bash
        curl -X POST http://localhost:4001/api/v1/appointments \\
          -H "Authorization: Bearer {access_token}" \\
          -H "Content-Type: application/json" \\
          -d '{
            "appointment": {
              "doctor_id": 2,
              "scheduled_at": "2025-10-25T14:00:00Z",
              "notes": "Consultation de suivi"
            }
          }'
        ```

        ## 🛡️ Permissions

        | Rôle | DME (lecture) | DME (écriture) | Appointments | Admin |
        |------|---------------|----------------|--------------|-------|
        | **Patient** | Ses propres DME | ❌ | Créer ses RDV | ❌ |
        | **Doctor** | Ses patients | ✅ Créer/Modifier | Tous ses RDV | ❌ |
        | **Admin** | Tous | ✅ Tous | Tous | ✅ |

        ## 🔗 Liens Utiles

        - Documentation complète: `/api/openapi`
        - Postman Collection: Voir `Telemed_API.postman_collection.json`
        - Code source: https://github.com/votre-org/telemed
        - Support: support@telemed.fr

        ## 📌 Notes Importantes

        - Tous les timestamps sont en **UTC** (ISO 8601)
        - Les tokens expirent après **1 heure** (refresh après)
        - Taille max upload: **50 MB**
        - Rate limit: 100 requêtes/minute (par IP)

        ---

        **Version**: 1.0.0
        **Dernière mise à jour**: 19 octobre 2025
        **Statut**: ✅ Production Ready
        """,
        version: "1.0.0",
        contact: %Contact{
          name: "Support Telemed",
          email: "support@telemed.fr",
          url: "https://telemed.fr/support"
        },
        license: %License{
          name: "MIT",
          url: "https://opensource.org/licenses/MIT"
        }
      },
            servers: [
              %Server{
                url: "http://localhost:4001",
                description: "🔧 Serveur Local (Développement)"
              },
        %Server{
          url: "https://staging.telemed.fr/api/v1",
          description: "🧪 Staging (Tests)"
        },
        %Server{
          url: "https://api.telemed.fr/api/v1",
          description: "🚀 Production"
        }
      ],
      paths: OpenApiSpex.Paths.from_router(Router),
      components: %Components{
        securitySchemes: %{
          "bearer" => %SecurityScheme{
            type: "http",
            scheme: "bearer",
            bearerFormat: "JWT",
            description: """
            Authentification JWT via header Authorization.

            **Format**: `Authorization: Bearer {access_token}`

            **Obtenir un token**:
            1. POST /api/v1/auth/register (créer compte)
            2. POST /api/v1/auth/login (se connecter)
            3. Copier le `access_token` de la réponse
            4. L'utiliser dans ce champ

            **Expiration**: 1 heure
            **Renouvellement**: POST /api/v1/auth/refresh avec `refresh_token`
            """
          }
        }
      },
      security: [
        %{"bearer" => []}
      ],
      tags: [
        %{name: "Authentication", description: "🔐 Inscription, connexion, gestion des tokens"},
        %{name: "Users", description: "👤 Gestion profil utilisateur"},
        %{name: "Medical Records", description: "📋 Dossiers Médicaux Électroniques (DME) - Structure SOAP"},
        %{name: "Appointments", description: "📅 Rendez-vous médicaux - Planification et gestion"},
        %{name: "Notifications", description: "🔔 Notifications temps réel - Alertes et rappels"},
        %{name: "Documents", description: "📎 Upload/Download documents médicaux (ordonnances, résultats)"},
        %{name: "Health", description: "❤️ Health checks et monitoring"}
      ]
    }
    |> OpenApiSpex.resolve_schema_modules()
  end
end
