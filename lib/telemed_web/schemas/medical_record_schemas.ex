defmodule TelemedWeb.Schemas.MedicalRecord do
  @moduledoc """
  Schemas OpenAPI pour les dossiers médicaux électroniques (DME)
  """

  require OpenApiSpex
  alias OpenApiSpex.Schema

  defmodule MedicalRecordResponse do
    @moduledoc "Réponse contenant un DME"
    OpenApiSpex.schema(%{
      title: "MedicalRecordResponse",
      description: "Dossier médical électronique complet",
      type: :object,
      properties: %{
        id: %Schema{type: :integer, example: 1},
        nom: %Schema{type: :string, example: "Jean Dupont"},
        age: %Schema{type: :integer, example: 45},
        category: %Schema{
          type: :string,
          enum: ["consultation", "exam", "treatment", "follow_up", "emergency"],
          example: "consultation"
        },
        priority: %Schema{
          type: :string,
          enum: ["low", "normal", "high", "urgent"],
          example: "normal"
        },
        status: %Schema{
          type: :string,
          enum: ["active", "archived", "draft"],
          example: "active"
        },
        record_type: %Schema{type: :string, example: "general"},
        soap_subjective: %Schema{
          type: :string,
          description: "S - Subjectif: Symptômes rapportés par le patient",
          example: "Patient se plaint de maux de tête persistants depuis 3 jours"
        },
        soap_objective: %Schema{
          type: :string,
          description: "O - Objectif: Observations médicales",
          example: "Tension: 130/85 mmHg, Température: 37.2°C, Pouls: 75 bpm"
        },
        soap_assessment: %Schema{
          type: :string,
          description: "A - Assessment: Diagnostic",
          example: "Possible migraine. Pas de signe de gravité."
        },
        soap_plan: %Schema{
          type: :string,
          description: "P - Plan: Traitement et suivi",
          example: "Paracétamol 1g 3x/jour. Revoir si symptômes persistent > 5j."
        },
        tags: %Schema{
          type: :array,
          items: %Schema{type: :string},
          description: "Tags pour classification",
          example: ["migraine", "suivi_requis", "prescription"]
        },
        consultation_date: %Schema{
          type: :string,
          format: :"date-time",
          example: "2025-10-19T14:00:00Z"
        },
        patient_id: %Schema{type: :integer, example: 1},
        doctor_id: %Schema{type: :integer, example: 2},
        inserted_at: %Schema{type: :string, format: :"date-time"},
        updated_at: %Schema{type: :string, format: :"date-time"}
      },
      example: %{
        "id" => 1,
        "nom" => "Jean Dupont",
        "age" => 45,
        "category" => "consultation",
        "priority" => "normal",
        "status" => "active",
        "soap_subjective" => "Patient se plaint de maux de tête",
        "soap_objective" => "Tension: 130/85 mmHg",
        "soap_assessment" => "Possible migraine",
        "soap_plan" => "Paracétamol 1g 3x/jour",
        "tags" => ["migraine", "suivi_requis"],
        "consultation_date" => "2025-10-19T14:00:00Z",
        "patient_id" => 1,
        "doctor_id" => 2,
        "inserted_at" => "2025-10-19T14:00:00Z",
        "updated_at" => "2025-10-19T14:30:00Z"
      }
    })
  end

  defmodule CreateMedicalRecordRequest do
    @moduledoc "Requête de création DME"
    OpenApiSpex.schema(%{
      title: "CreateMedicalRecordRequest",
      description: "Données pour créer un nouveau DME",
      type: :object,
      properties: %{
        medical_record: %Schema{
          type: :object,
          required: [:user_id, :nom, :age],
          properties: %{
            user_id: %Schema{
              type: :integer,
              description: "ID du patient",
              example: 1
            },
            nom: %Schema{
              type: :string,
              description: "Nom complet du patient",
              example: "Jean Dupont"
            },
            age: %Schema{
              type: :integer,
              minimum: 0,
              maximum: 150,
              description: "Âge du patient",
              example: 45
            },
            category: %Schema{
              type: :string,
              enum: ["consultation", "exam", "treatment", "follow_up", "emergency"],
              description: "Catégorie du dossier",
              example: "consultation"
            },
            priority: %Schema{
              type: :string,
              enum: ["low", "normal", "high", "urgent"],
              description: "Niveau de priorité",
              example: "normal"
            },
            soap_subjective: %Schema{type: :string, description: "Symptômes patient"},
            soap_objective: %Schema{type: :string, description: "Observations médicales"},
            soap_assessment: %Schema{type: :string, description: "Diagnostic"},
            soap_plan: %Schema{type: :string, description: "Plan de traitement"},
            tags: %Schema{
              type: :array,
              items: %Schema{type: :string},
              description: "Tags (optionnel)"
            }
          }
        }
      },
      required: [:medical_record]
    })
  end

  defmodule MedicalRecordListResponse do
    @moduledoc "Liste de DME"
    OpenApiSpex.schema(%{
      title: "MedicalRecordListResponse",
      description: "Liste paginée de dossiers médicaux",
      type: :object,
      properties: %{
        data: %Schema{
          type: :array,
          items: MedicalRecordResponse
        },
        meta: %Schema{
          type: :object,
          properties: %{
            total: %Schema{type: :integer, example: 42},
            page: %Schema{type: :integer, example: 1},
            per_page: %Schema{type: :integer, example: 20}
          }
        }
      }
    })
  end
end
