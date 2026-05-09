# 🚀 CountIt - Aplikacja do dzielenia wydatków w grupie

CountIt to aplikacja mobilna napisana we Flutterze, wspierana przez backend oparty na Node.js i MongoDB. Poniższa instrukcja przeprowadzi Cię krok po kroku przez proces instalacji narzędzi oraz uruchomienia aplikacji.

---

## ⚠️ Krok 1: Wymagania wstępne

Aby uruchomić ten projekt na swoim komputerze, potrzebujesz dwóch głównych środowisk:
1. **Node.js** (do uruchomienia serwera i bazy danych)
   - Pobierz z oficjalnej strony: [nodejs.org](https://nodejs.org/) (Wybierz wersję LTS i zainstaluj klikając "Dalej").
2. **Flutter SDK** (do kompilacji i odpalenia aplikacji mobilnej)
   - Jeśli korzystasz z programu **Visual Studio Code**, proces instalacji znajdziesz w następnym kroku.

---

## ⚙️ Krok 2: Instalacja Fluttera (przez VS Code)

Jeśli nie masz jeszcze pobranego Fluttera, Visual Studio Code potrafi zrobić to automatycznie:

1. Otwórz program Visual Studio Code.
2. Wciśnij na klawiaturze `Ctrl + Shift + P` (otworzy się pasek poleceń u góry).
3. Wpisz słowo `flutter` i wybierz z listy **"Flutter: New Project"**.
4. W prawym dolnym rogu wyskoczy okienko z prośbą o znalezienie środowiska SDK. Kliknij przycisk **"Download SDK"**.
5. Wybierz folder, w którym chcesz zainstalować narzędzia (najlepiej na dysku `C:\` lub na Pulpicie) i kliknij **"Clone Flutter"**.
6. Poczekaj, aż SDK się pobierze. Gdy na końcu w dolnym rogu wyskoczy powiadomienie, **koniecznie kliknij "Add SDK to PATH"**!
7. **BARDZO WAŻNE:** Po całej procedurze zamknij całkowicie program VS Code i otwórz go ponownie, aby załadował nowe zmienne środowiskowe.

---

## 🚀 Krok 3: Uruchomienie projektu

Aplikacja składa się z dwóch niezależnych części (backendu i frontendu). Musisz włączyć serwer i samą aplikację w dwóch osobnych terminalach wewnątrz tego folderu.

Otwórz projekt w VS Code i na górnym pasku wybierz *Terminal -> New Terminal*. Otwórz od razu dwa takie terminale.

### 👉 TERMINAL 1 (Serwer Backendowy)
Ten terminal uruchomi w tle darmową bazę danych w pamięci RAM i API.
1. Wejdź w folder backendu:
   ```bash
   cd backend
   ```
2. Zainstaluj paczki:
   ```bash
   npm install
   ```
3. Uruchom bazę i serwer:
   ```bash
   npm run dev
   ```
*(Zostaw to okno włączone w tle na zawsze, musi działać podczas korzystania z aplikacji)*

### 👉 TERMINAL 2 (Aplikacja Mobilna Flutter)
Ten terminal skompiluje aplikację mobilną do uruchomienia w przeglądarce.
1. Wejdź w folder apki:
   ```bash
   cd mobile
   ```
2. Pobierz zależności:
   ```bash
   flutter pub get
   ```
3. Uruchom apkę (w trybie webowym pod Chrome):
   ```bash
   flutter run -d chrome
   ```
*(Uwaga: pierwsze odpalenie pobiera dodatkowe pliki systemowe do przeglądarki i potrafi potrwać około 2-3 minut! Bądź cierpliwy.)*

---

## 🪄 Krok 4: Tryb prezentacji "Prawdziwego Telefonu"

Gdy po wpisaniu powyższej komendy aplikacja otworzy się w nowym oknie Google Chrome, na początku zobaczysz szeroką stronę. Żeby aplikacja wyglądała i zachowywała się jak na prawdziwym smartfonie (idealne do pokazów!):

1. Wciśnij **`F12`** w otwartej przeglądarce Chrome. Otworzy się panel boczny dla deweloperów.
2. Kliknij w lewym górnym rogu tego panelu ikonkę **telefonu i tabletu** (lub wciśnij `Ctrl + Shift + M`).
3. Szeroki ekran z aplikacją zwinie się na środku okna w prostokąt.
4. Na samym szczycie strony, na rozwijanej liście ("Dimensions") zmień *Responsive* na np. **iPhone 14 Pro Max** lub **Samsung Galaxy S20 Ultra**.
5. Wciśnij **`F5`**, aby odświeżyć stronę.

Będziesz miał idealny symulator z proporcjami telefonu. Kursor myszy w tym obszarze zyska obrys okręgu i będzie symulował dotyk palca (przeciąganie ekranu zamiast rolki). Gotowe!
