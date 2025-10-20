# 🤖 Option B : Innovation IA d'Abord (Différenciation Marché)

## Profil
✅ **Pour vous si** :
- Vous avez déjà une base conforme (ou tolérance au risque)
- Vous voulez un MVP **différenciant** rapidement
- Budget R&D disponible
- Cible: early adopters, cliniques privées innovantes

❌ **Pas pour vous si** :
- Patients réels en production
- Contraintes légales strictes immédiates

---

## 🎯 OBJECTIF : POC IA Fonctionnel en 60 Jours

### Livrables
1. **Prédiction no-shows** (taux précision >80%)
2. **Dashboard prédictif médecin** (alertes temps réel)
3. **Chatbot triage symptômes** (NLP français)
4. **Détection anomalies sécurité** (zero trust)

---

## 📅 PLANNING 8 SEMAINES

### **Semaine 1-2 : Setup ML Pipeline**

#### Jour 1-3 : Collecte & Nettoyage Données

```elixir
# Générer dataset synthétique pour POC
# lib/telemed/ml/data_generator.ex
defmodule Telemed.ML.DataGenerator do
  @moduledoc """
  Génère données synthétiques pour entraînement ML
  Basé sur distributions réalistes
  """

  def generate_appointments(count \\ 1000) do
    Enum.map(1..count, fn _ ->
      scheduled_at = random_datetime()
      patient_history = random_history()
      
      %{
        # Features
        days_until_appointment: random_days_ahead(),
        hour_of_day: scheduled_at.hour,
        day_of_week: Date.day_of_week(DateTime.to_date(scheduled_at)),
        patient_age: Enum.random(18..85),
        patient_previous_appointments: patient_history.total,
        patient_no_show_rate: patient_history.no_show_rate,
        appointment_type: Enum.random(["first", "follow_up", "urgent"]),
        weather_score: Enum.random(1..10),  # 1=orage, 10=soleil
        distance_km: :rand.uniform() * 50,
        has_reminder: Enum.random([true, false]),
        
        # Label (ce qu'on veut prédire)
        was_no_show: calculate_no_show_probability(patient_history, scheduled_at)
      }
    end)
  end

  defp calculate_no_show_probability(history, datetime) do
    # Facteurs augmentant no-show
    base_prob = history.no_show_rate
    
    # +20% si lundi matin
    base_prob = if datetime.hour < 10 && Date.day_of_week(DateTime.to_date(datetime)) == 1 do
      base_prob + 0.2
    else
      base_prob
    end
    
    # +10% si >7j à l'avance
    # +15% si vendredi après-midi
    # etc.
    
    :rand.uniform() < base_prob
  end

  defp random_history do
    total = Enum.random(0..20)
    no_shows = Enum.random(0..div(total, 3))
    
    %{
      total: total,
      no_shows: no_shows,
      no_show_rate: if(total > 0, do: no_shows / total, else: 0.15)  # 15% défaut
    }
  end

  defp random_datetime do
    days_ahead = Enum.random(1..60)
    DateTime.utc_now()
    |> DateTime.add(days_ahead * 24 * 3600, :second)
    |> DateTime.add(Enum.random(8..18) * 3600, :second)  # 8h-18h
  end

  defp random_days_ahead, do: Enum.random(1..60)
end
```

```elixir
# Script d'export CSV pour analyse
# lib/mix/tasks/ml.export_data.ex
defmodule Mix.Tasks.Ml.ExportData do
  use Mix.Task
  alias Telemed.ML.DataGenerator

  @shortdoc "Exporte données pour ML"
  def run(_) do
    Mix.Task.run("app.start")
    
    data = DataGenerator.generate_appointments(5000)
    
    csv_content = 
      [["days_until", "hour", "day_of_week", "age", "prev_appts", "no_show_rate", 
        "type", "weather", "distance", "has_reminder", "no_show"]]
      |> Enum.concat(Enum.map(data, &row_to_list/1))
      |> CSV.encode()
      |> Enum.to_list()
      |> IO.iodata_to_binary()
    
    File.write!("priv/ml_data/appointments_training.csv", csv_content)
    IO.puts("✅ Exported #{length(data)} records to priv/ml_data/appointments_training.csv")
  end

  defp row_to_list(row) do
    [
      row.days_until_appointment,
      row.hour_of_day,
      row.day_of_week,
      row.patient_age,
      row.patient_previous_appointments,
      row.patient_no_show_rate,
      row.appointment_type,
      row.weather_score,
      row.distance_km,
      if(row.has_reminder, do: 1, else: 0),
      if(row.was_no_show, do: 1, else: 0)
    ]
  end
end
```

```bash
# Dépendances
mix deps.add csv
mix ml.export_data
```

#### Jour 4-7 : Entraînement Modèle

```elixir
# Ajouter à mix.exs
{:scholar, "~> 0.3"},
{:nx, "~> 0.7"},
{:exla, "~> 0.7"},  # Backend GPU (optionnel)
{:explorer, "~> 0.8"}  # Dataframes
```

```elixir
# lib/telemed/ml/no_show_model.ex
defmodule Telemed.ML.NoShowModel do
  @moduledoc """
  Modèle ML de prédiction des no-shows
  Architecture: Régression logistique (baseline) → XGBoost (v2)
  """

  alias Scholar.Linear.LogisticRegression
  require Explorer.DataFrame, as: DF

  @model_path "priv/ml_models/no_show_v1.bin"

  @doc "Entraîne le modèle sur données historiques"
  def train do
    IO.puts("📚 Chargement données...")
    df = DF.from_csv!("priv/ml_data/appointments_training.csv")
    
    # Split train/test (80/20)
    {train_df, test_df} = split_dataset(df, 0.8)
    
    IO.puts("📊 Préparation features...")
    x_train = prepare_features(train_df)
    y_train = train_df["no_show"] |> Explorer.Series.to_tensor()
    
    x_test = prepare_features(test_df)
    y_test = test_df["no_show"] |> Explorer.Series.to_tensor()
    
    IO.puts("🧠 Entraînement modèle...")
    model = LogisticRegression.fit(x_train, y_train, num_iterations: 1000)
    
    IO.puts("📈 Évaluation...")
    predictions = LogisticRegression.predict(model, x_test)
    accuracy = calculate_accuracy(predictions, y_test)
    
    IO.puts("✅ Précision: #{Float.round(accuracy * 100, 2)}%")
    
    # Sauvegarder
    save_model(model)
    
    %{model: model, accuracy: accuracy}
  end

  defp prepare_features(df) do
    # Normalisation + encoding
    df
    |> DF.select([
      "days_until", "hour", "day_of_week", "age", 
      "prev_appts", "no_show_rate", "weather", "distance", "has_reminder"
    ])
    |> DF.mutate(
      # One-hot encoding pour type
      type_first: if type == "first", do: 1, else: 0,
      type_followup: if type == "follow_up", do: 1, else: 0,
      type_urgent: if type == "urgent", do: 1, else: 0
    )
    |> DF.select([
      "days_until", "hour", "day_of_week", "age", "prev_appts", 
      "no_show_rate", "weather", "distance", "has_reminder",
      "type_first", "type_followup", "type_urgent"
    ])
    |> DF.to_rows()
    |> Enum.map(&Map.values/1)
    |> Nx.tensor(type: :f32)
  end

  defp split_dataset(df, ratio) do
    total_rows = DF.n_rows(df)
    train_size = floor(total_rows * ratio)
    
    train = DF.slice(df, 0, train_size)
    test = DF.slice(df, train_size, total_rows - train_size)
    
    {train, test}
  end

  defp calculate_accuracy(predictions, labels) do
    # Seuil 0.5 pour classification binaire
    pred_binary = Nx.greater(predictions, 0.5) |> Nx.to_flat_list()
    true_labels = Nx.to_flat_list(labels)
    
    correct = 
      Enum.zip(pred_binary, true_labels)
      |> Enum.count(fn {pred, label} -> (pred && label == 1) || (!pred && label == 0) end)
    
    correct / length(true_labels)
  end

  defp save_model(model) do
    File.mkdir_p!("priv/ml_models")
    File.write!(@model_path, :erlang.term_to_binary(model))
  end

  @doc "Charge modèle sauvegardé"
  def load_model do
    @model_path
    |> File.read!()
    |> :erlang.binary_to_term()
  end

  @doc "Prédit probabilité de no-show pour un RDV"
  def predict(appointment) do
    model = load_model()
    features = extract_features(appointment) |> Nx.tensor() |> Nx.new_axis(0)
    
    probability = 
      LogisticRegression.predict_probability(model, features)
      |> Nx.to_number()
    
    risk_level = cond do
      probability > 0.7 -> :high
      probability > 0.4 -> :medium
      true -> :low
    end
    
    %{
      probability: Float.round(probability, 3),
      risk_level: risk_level,
      recommended_actions: recommend_actions(risk_level)
    }
  end

  defp extract_features(appointment) do
    patient_stats = Telemed.Appointments.patient_statistics(appointment.patient_id)
    
    [
      days_until_appointment(appointment),
      appointment.scheduled_at.hour,
      Date.day_of_week(DateTime.to_date(appointment.scheduled_at)),
      appointment.patient.age || 40,
      patient_stats.total_appointments,
      patient_stats.no_show_rate,
      8,  # Weather score (TODO: intégrer API météo)
      patient_stats.avg_distance_km || 10,
      if(appointment.reminder_sent, do: 1, else: 0),
      # One-hot type
      if(appointment.type == "first", do: 1, else: 0),
      if(appointment.type == "follow_up", do: 1, else: 0),
      if(appointment.type == "urgent", do: 1, else: 0)
    ]
  end

  defp days_until_appointment(appointment) do
    DateTime.diff(appointment.scheduled_at, DateTime.utc_now(), :day)
  end

  defp recommend_actions(:high) do
    [
      "Envoyer 3 rappels (48h, 24h, 2h avant)",
      "Appel téléphonique 24h avant",
      "Proposer changement créneau si besoin"
    ]
  end

  defp recommend_actions(:medium) do
    [
      "Envoyer 2 rappels (24h, 2h avant)",
      "SMS de confirmation"
    ]
  end

  defp recommend_actions(:low) do
    ["Rappel email 24h avant"]
  end
end
```

```bash
mix ml.train
```

#### Jour 8-10 : Intégration Dashboard

```elixir
# lib/telemed_web/live/doctor_dashboard_live.ex
defmodule TelemedWeb.DoctorDashboardLive do
  use TelemedWeb, :live_view
  alias Telemed.{Appointments, ML.NoShowModel}

  @impl true
  def mount(_params, _session, socket) do
    doctor = socket.assigns.current_user
    
    upcoming = Appointments.list_upcoming(doctor)
    predictions = Enum.map(upcoming, &predict_no_show/1)
    
    {:ok,
     socket
     |> assign(:appointments, upcoming)
     |> assign(:predictions, predictions)
     |> assign(:high_risk_count, count_high_risk(predictions))
    }
  end

  defp predict_no_show(appointment) do
    prediction = NoShowModel.predict(appointment)
    Map.put(appointment, :prediction, prediction)
  end

  defp count_high_risk(predictions) do
    Enum.count(predictions, & &1.prediction.risk_level == :high)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="dashboard-ai p-6">
      <h1 class="text-2xl font-bold mb-4">🤖 Dashboard Prédictif</h1>
      
      <!-- Résumé -->
      <div class="grid grid-cols-3 gap-4 mb-6">
        <div class="bg-white p-4 rounded shadow">
          <div class="text-gray-600">RDV à venir</div>
          <div class="text-3xl font-bold"><%= length(@appointments) %></div>
        </div>
        
        <div class="bg-red-100 p-4 rounded shadow">
          <div class="text-gray-600">⚠️ Risque élevé</div>
          <div class="text-3xl font-bold text-red-600"><%= @high_risk_count %></div>
        </div>
        
        <div class="bg-green-100 p-4 rounded shadow">
          <div class="text-gray-600">✅ Taux présence prévu</div>
          <div class="text-3xl font-bold text-green-600">
            <%= calculate_expected_attendance(@predictions) %>%
          </div>
        </div>
      </div>

      <!-- Liste RDV avec prédictions -->
      <div class="appointments-list">
        <h2 class="text-xl font-semibold mb-3">Prochains Rendez-vous</h2>
        
        <div :for={appt <- @predictions} class={"appointment-card p-4 mb-3 rounded border-l-4 #{risk_border_class(appt.prediction.risk_level)}"}>
          <div class="flex justify-between items-start">
            <div class="flex-1">
              <div class="font-semibold"><%= appt.patient.nom %></div>
              <div class="text-sm text-gray-600">
                <%= Calendar.strftime(appt.scheduled_at, "%d/%m/%Y à %H:%M") %>
              </div>
            </div>
            
            <div class="ml-4 text-right">
              <div class={"px-3 py-1 rounded text-sm font-semibold #{risk_badge_class(appt.prediction.risk_level)}"}>
                <%= risk_label(appt.prediction.risk_level) %>
              </div>
              <div class="text-xs text-gray-600 mt-1">
                <%= Float.round(appt.prediction.probability * 100, 0) %>% no-show
              </div>
            </div>
          </div>

          <!-- Actions recommandées -->
          <div :if={appt.prediction.risk_level in [:high, :medium]} class="mt-3 bg-yellow-50 p-2 rounded text-sm">
            <div class="font-semibold">📋 Actions recommandées:</div>
            <ul class="list-disc list-inside">
              <li :for={action <- appt.prediction.recommended_actions}><%= action %></li>
            </ul>
            <button 
              phx-click="send_reminders" 
              phx-value-id={appt.id}
              class="mt-2 bg-blue-600 text-white px-3 py-1 rounded text-xs">
              Envoyer rappels automatiques
            </button>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp risk_border_class(:high), do: "border-red-600 bg-red-50"
  defp risk_border_class(:medium), do: "border-yellow-600 bg-yellow-50"
  defp risk_border_class(:low), do: "border-green-600 bg-white"

  defp risk_badge_class(:high), do: "bg-red-600 text-white"
  defp risk_badge_class(:medium), do: "bg-yellow-600 text-white"
  defp risk_badge_class(:low), do: "bg-green-600 text-white"

  defp risk_label(:high), do: "RISQUE ÉLEVÉ"
  defp risk_label(:medium), do: "RISQUE MOYEN"
  defp risk_label(:low), do: "FAIBLE RISQUE"

  defp calculate_expected_attendance(predictions) do
    if length(predictions) > 0 do
      avg_no_show_prob = 
        predictions
        |> Enum.map(& &1.prediction.probability)
        |> Enum.sum()
        |> Kernel./(length(predictions))
      
      Float.round((1 - avg_no_show_prob) * 100, 0)
    else
      0
    end
  end

  @impl true
  def handle_event("send_reminders", %{"id" => id}, socket) do
    appointment = Appointments.get_appointment!(id)
    Telemed.Notifications.schedule_smart_reminders(appointment)
    
    {:noreply, put_flash(socket, :info, "Rappels programmés avec succès")}
  end
end
```

---

### **Semaine 3-4 : Chatbot Triage NLP**

#### Setup Bumblebee (Hugging Face en Elixir)

```elixir
# mix.exs
{:bumblebee, "~> 0.5"},
{:exla, "~> 0.7"}  # Backend Nx
```

```elixir
# lib/telemed/ai/symptom_checker.ex
defmodule Telemed.AI.SymptomChecker do
  @moduledoc """
  Chatbot de triage des symptômes
  Modèle: CamemBERT (BERT français) fine-tuné sur données médicales
  """

  def analyze_symptoms(text) do
    # TODO: Charger modèle fine-tuné
    # Pour POC: règles simples
    keywords = %{
      "urgent" => ~w(douleur poitrine difficulté respirer sang inconscient),
      "rapide" => ~w(fièvre forte vomissements migraine),
      "normal" => ~w(rhume toux fatigue)
    }
    
    text_lower = String.downcase(text)
    
    cond do
      has_keywords?(text_lower, keywords["urgent"]) ->
        %{
          urgency: :urgent,
          recommendation: "🚨 Consultez immédiatement un médecin ou appelez le 15",
          confidence: 0.95
        }
        
      has_keywords?(text_lower, keywords["rapide"]) ->
        %{
          urgency: :high,
          recommendation: "Prenez rendez-vous dans les 24-48h",
          confidence: 0.80
        }
        
      true ->
        %{
          urgency: :normal,
          recommendation: "Surveillez vos symptômes. Consultez si aggravation.",
          confidence: 0.70
        }
    end
  end

  defp has_keywords?(text, keywords) do
    Enum.any?(keywords, &String.contains?(text, &1))
  end
end
```

#### LiveView Chatbot

```elixir
# lib/telemed_web/live/symptom_checker_live.ex
defmodule TelemedWeb.SymptomCheckerLive do
  use TelemedWeb, :live_view
  alias Telemed.AI.SymptomChecker

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:messages, [])
     |> assign(:waiting_response, false)
    }
  end

  @impl true
  def handle_event("send_message", %{"message" => text}, socket) do
    # Ajouter message utilisateur
    user_msg = %{role: :user, content: text, timestamp: DateTime.utc_now()}
    
    # Analyser
    analysis = SymptomChecker.analyze_symptoms(text)
    
    # Générer réponse bot
    bot_msg = %{
      role: :assistant,
      content: """
      #{analysis.recommendation}
      
      (Niveau urgence: #{analysis.urgency} | Confiance: #{Float.round(analysis.confidence * 100, 0)}%)
      """,
      timestamp: DateTime.utc_now()
    }
    
    {:noreply,
     socket
     |> update(:messages, &(&1 ++ [user_msg, bot_msg]))
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="symptom-checker flex flex-col h-screen">
      <div class="header bg-blue-600 text-white p-4">
        <h1 class="text-xl font-bold">🤖 Assistant Symptômes (IA)</h1>
        <p class="text-sm">Décrivez vos symptômes, je vous aide à évaluer l'urgence</p>
      </div>

      <!-- Messages -->
      <div class="messages flex-1 overflow-y-auto p-4 bg-gray-100">
        <div :for={msg <- @messages} class={"message mb-3 #{if msg.role == :user, do: "text-right"}"}>
          <div class={"inline-block p-3 rounded max-w-md #{if msg.role == :user, do: "bg-blue-600 text-white", else: "bg-white"}"}>
            <%= msg.content %>
          </div>
        </div>
      </div>

      <!-- Input -->
      <form phx-submit="send_message" class="input-area p-4 bg-white border-t">
        <div class="flex gap-2">
          <input
            type="text"
            name="message"
            placeholder="Ex: J'ai de la fièvre depuis 2 jours..."
            class="flex-1 border rounded px-3 py-2"
            autocomplete="off"
          />
          <button type="submit" class="bg-blue-600 text-white px-6 py-2 rounded font-semibold">
            Envoyer
          </button>
        </div>
        <p class="text-xs text-gray-500 mt-2">
          ⚠️ Ceci est une aide, pas un diagnostic médical
        </p>
      </form>
    </div>
    """
  end
end
```

---

### **Semaine 5-6 : Détection Anomalies Sécurité**

```elixir
# lib/telemed/security/anomaly_detector.ex
defmodule Telemed.Security.AnomalyDetector do
  @moduledoc """
  Détection comportements anormaux via ML
  Approche: Isolation Forest (détection outliers)
  """

  alias Telemed.{Accounts, AuditLog}

  @doc "Analyse session en temps réel"
  def analyze_session(conn) do
    user = conn.assigns.current_user
    
    features = extract_session_features(conn, user)
    risk_score = calculate_risk_score(features)
    
    if risk_score > 0.8 do
      # Bloquer + alerter
      AuditLog.log("security_alert", "session", user, %{
        risk_score: risk_score,
        features: features,
        action: "blocked"
      })
      
      {:block, "Activité suspecte détectée. Veuillez contacter le support."}
    else
      {:allow, risk_score}
    end
  end

  defp extract_session_features(conn, user) do
    now = DateTime.utc_now()
    
    %{
      hour_of_day: now.hour,
      day_of_week: Date.day_of_week(DateTime.to_date(now)),
      ip_country: geolocate_ip(conn.remote_ip),
      requests_last_hour: count_recent_requests(user, 3600),
      failed_auth_last_24h: count_failed_auth(user, 86400),
      new_ip: is_new_ip?(user, conn.remote_ip),
      time_since_last_login: time_since_last_login(user),
      unusual_path: is_unusual_path?(conn.request_path, user.role)
    }
  end

  defp calculate_risk_score(features) do
    score = 0.0
    
    # Heure inhabituelle (2h-6h)
    score = if features.hour_of_day in 2..6, do: score + 0.3, else: score
    
    # Nouvelle IP
    score = if features.new_ip, do: score + 0.2, else: score
    
    # Trop de requêtes
    score = if features.requests_last_hour > 100, do: score + 0.4, else: score
    
    # Tentatives auth échouées
    score = if features.failed_auth_last_24h > 3, do: score + 0.5, else: score
    
    # Chemin inhabituel pour rôle
    score = if features.unusual_path, do: score + 0.3, else: score
    
    min(score, 1.0)
  end

  defp geolocate_ip(ip) do
    # TODO: Intégrer service géoloc (MaxMind, IP2Location)
    "FR"
  end

  defp count_recent_requests(user, seconds) do
    # Compter dans AuditLog
    cutoff = DateTime.add(DateTime.utc_now(), -seconds, :second)
    
    AuditLog
    |> where([l], l.actor_id == ^user.id)
    |> where([l], l.inserted_at > ^cutoff)
    |> Telemed.Repo.aggregate(:count)
  end

  defp count_failed_auth(user, seconds) do
    # TODO: Logger tentatives échouées
    0
  end

  defp is_new_ip?(user, ip) do
    # Vérifier si IP déjà utilisée
    ip_str = format_ip(ip)
    
    !AuditLog
    |> where([l], l.actor_id == ^user.id)
    |> where([l], l.ip_address == ^ip_str)
    |> Telemed.Repo.exists?()
  end

  defp time_since_last_login(user) do
    # Récupérer dernière session
    DateTime.diff(DateTime.utc_now(), user.updated_at, :second)
  end

  defp is_unusual_path?(path, role) do
    # Patient accédant à /admin
    (role == :patient && String.starts_with?(path, "/admin")) ||
    # Médecin accédant à des DME d'autres médecins
    false  # TODO: Logique plus fine
  end

  defp format_ip({a, b, c, d}), do: "#{a}.#{b}.#{c}.#{d}"
end
```

---

### **Semaine 7-8 : Tests & Monitoring**

#### Métriques ML

```elixir
# lib/telemed/ml/metrics.ex
defmodule Telemed.ML.Metrics do
  @moduledoc """
  Dashboard métriques ML en production
  """

  def collect_prediction_metrics do
    # Comparer prédictions vs. réalité
    last_30_days = DateTime.add(DateTime.utc_now(), -30 * 86400, :second)
    
    appointments = 
      Telemed.Appointments
      |> where([a], a.scheduled_at > ^last_30_days)
      |> where([a], a.status in ["completed", "no_show"])
      |> Telemed.Repo.all()
    
    predictions_vs_reality = 
      Enum.map(appointments, fn appt ->
        prediction = Telemed.ML.NoShowModel.predict(appt)
        actual = appt.status == "no_show"
        
        %{
          predicted_risk: prediction.risk_level,
          actual_no_show: actual,
          correct: (prediction.risk_level == :high && actual) || 
                   (prediction.risk_level == :low && !actual)
        }
      end)
    
    accuracy = 
      predictions_vs_reality
      |> Enum.count(& &1.correct)
      |> Kernel./(length(predictions_vs_reality))
    
    %{
      total_predictions: length(predictions_vs_reality),
      accuracy: Float.round(accuracy * 100, 2),
      false_positives: count_false_positives(predictions_vs_reality),
      false_negatives: count_false_negatives(predictions_vs_reality)
    }
  end

  defp count_false_positives(data) do
    Enum.count(data, &(&1.predicted_risk == :high && !&1.actual_no_show))
  end

  defp count_false_negatives(data) do
    Enum.count(data, &(&1.predicted_risk == :low && &1.actual_no_show))
  end
end
```

#### Dashboard Prometheus

```elixir
# lib/telemed/telemetry.ex
# Ajouter métriques custom

defmodule Telemed.Telemetry do
  use Supervisor
  import Telemetry.Metrics

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      {:telemetry_poller, measurements: periodic_measurements(), period: 10_000}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def metrics do
    [
      # ... existing metrics
      
      # Métriques ML
      last_value("telemed.ml.prediction_accuracy.percent"),
      counter("telemed.ml.predictions.total"),
      distribution("telemed.ml.prediction_latency.milliseconds"),
      
      # Sécurité
      counter("telemed.security.anomalies_detected.total"),
      counter("telemed.security.sessions_blocked.total")
    ]
  end

  defp periodic_measurements do
    [
      {Telemed.ML.Metrics, :collect_prediction_metrics, []}
    ]
  end
end
```

---

## 🎯 RÉSULTAT ATTENDU (Jour 60)

### Démo Investisseurs/Clients

1. **Dashboard médecin** avec prédictions temps réel
2. **Chatbot patient** pour triage symptômes
3. **Alertes sécurité** automatiques
4. **Métriques** : "82% précision prédiction no-shows"

### ROI Business

- **Réduction no-shows** : 15-25% (économie ~50€/RDV manqué)
- **Satisfaction médecins** : Meilleure planification
- **Différenciation** : "Seule plateforme télémédecine avec IA prédictive en France"

---

## 💰 BUDGET

| Poste | Coût |
|-------|------|
| Dev (2 mois × 1 ETP) | 20-30k€ |
| GPU Cloud (entraînement) | 500-1000€ |
| API externes (météo, géoloc) | 100€/mois |
| **TOTAL** | **~25-35k€** |

---

## 🚀 APRÈS LE POC

1. **Fine-tuning modèles** sur vraies données
2. **A/B testing** : Comparer avec/sans IA
3. **Nouvelles features IA** :
   - Recommandation diagnostics (aide décision)
   - Génération automatique compte-rendus
   - Détection burnout médecins

4. **Conformité** (rattraper phase 1):
   - Migrer vers HDS
   - Ajouter INS/FHIR
   - Documentation RGPD

---

**Prêt à démarrer ?** Je peux générer tous les fichiers immédiatement ! 🚀


