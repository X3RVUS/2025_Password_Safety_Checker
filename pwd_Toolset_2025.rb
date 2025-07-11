require 'io/console'
require 'artii'        # Für die ASCII-Art-Generierung
require 'pastel'       # Für alle Farbausgaben (ersetzt colorize)
require 'securerandom'

# --- INITIALISIERUNG ---
# Einmalige Erstellung der Objekte für die Wiederverwendung
PASTEL = Pastel.new
ARTII = Artii::Base.new(font: 'standard')

# --- VERBESSERTER ASCII TITEL (dynamisch generiert) ---
def print_title(text = "Passwort Tool")
  # Terminalbreite für die Zentrierung (Standard: 80)
  terminal_width = 80
  border = "═" * terminal_width
  
  # Generiere die ASCII-Kunst aus dem übergebenen Text
  ascii_text = ARTII.asciify(text)
  
  puts PASTEL.cyan(border)
  ascii_text.each_line do |line|
    # Zentriere jede Zeile und färbe sie ein
    puts PASTEL.bright_blue(line.chomp.center(terminal_width))
  end
  puts PASTEL.cyan(border)
  puts # Leerzeile für Abstand
end

# --- FUNKTION 1: PASSWORT PRÜFEN ---
def check_strength(password)
  {
    length: password.length >= 8,
    upper:  password.match?(/[A-Z]/),
    lower:  password.match?(/[a-z]/),
    digit:  password.match?(/[0-9]/),
    special: password.match?(/[!@#$%^&*()_+=\[\]{};':"\\|,.<>\/?~-]/)
  }
end

def run_checker_ui
  puts PASTEL.yellow("--- Kriterien prüfen ---")
  print "Geben Sie Ihr Passwort ein: "
  password = STDIN.noecho(&:gets).chomp
  puts PASTEL.dim("\n\nPasswort wird analysiert...")

  criteria_results = check_strength(password)
  score = criteria_results.values.count(true)
  strength_level = case score
                   when 0..1 then PASTEL.red("Sehr schwach")
                   when 2    then PASTEL.magenta("Schwach")
                   when 3    then PASTEL.yellow("Mittel")
                   when 4    then PASTEL.light_green("Stark")
                   when 5    then PASTEL.green("Sehr stark")
                   end

  puts "\nGesamtbewertung: #{strength_level} (#{score}/5 Kriterien erfüllt)"
  puts "\nDetaillierte Analyse:"
  criteria_labels = {
    length: "Mindestens 8 Zeichen lang",
    upper:  "Enthält Großbuchstaben",
    lower:  "Enthält Kleinbuchstaben",
    digit:  "Enthält Zahlen",
    special: "Enthält Sonderzeichen"
  }
  criteria_results.each do |criterion, met|
    icon = met ? PASTEL.green("✔") : PASTEL.red("✗")
    puts "#{icon} #{criteria_labels[criterion]}"
  end
end

# --- FUNKTION 2: SICHERES PASSWORT GENERIEREN ---
def generate_secure_password(length = 16)
  lower_chars   = ('a'..'z').to_a
  upper_chars   = ('A'..'Z').to_a
  digit_chars   = ('0'..'9').to_a
  special_chars = '!@#$%^&*()_-+='.split('')
  
  all_chars = lower_chars + upper_chars + digit_chars + special_chars
  
  password = []
  password << lower_chars.sample
  password << upper_chars.sample
  password << digit_chars.sample
  password << special_chars.sample
  
  (length - password.length).times { password << all_chars.sample }
  
  return password.shuffle.join
end

def run_generator_ui
  puts PASTEL.yellow("--- Sicheres Passwort generieren ---")
  print "Gewünschte Passwortlänge (Standard ist 16): "
  input = gets.chomp
  length = input.empty? ? 16 : input.to_i
  
  if length < 8
    puts PASTEL.red("\nWARNUNG: Eine Länge unter 8 ist nicht zu empfehlen.")
    length = 8
  end

  password = generate_secure_password(length)
  puts PASTEL.green("\nDein neues, sicheres Passwort lautet:")
  puts PASTEL.bold(password)
end

# --- FUNKTION 3: ZEIT ZUM KNACKEN BERECHNEN ---
def format_seconds(seconds)
  return "sofort" if seconds < 0.000001
  
  time_units = [['Jahrhundert', 3153600000], ['Jahrzehnt', 315360000], ['Jahr', 31536000],
                ['Monat', 2592000], ['Tag', 86400], ['Stunde', 3600], ['Minute', 60]]
  
  time_units.each do |name, amount|
    return "ca. #{(seconds / amount).round(1)} #{name}(e)" if seconds >= amount
  end
  "weniger als eine Minute"
end

def run_crack_time_ui
  puts PASTEL.yellow("--- Zeit zum Knacken berechnen ---")
  print "Geben Sie Ihr Passwort ein: "
  password = STDIN.noecho(&:gets).chomp

  pool = 0
  pool += 26 if password.match?(/[a-z]/)
  pool += 26 if password.match?(/[A-Z]/)
  pool += 10 if password.match?(/[0-9]/)
  pool += 32 if password.match?(/[!@#$%^&*()_+=\[\]{};':"\\|,.<>\/?~-]/)
  
  if pool == 0
    puts PASTEL.red("\nPasswort ist leer oder enthält unbekannte Zeichen.")
    return
  end

  guesses_per_second = 100_000_000_000
  combinations = pool**password.length
  seconds_to_crack = combinations / (2.0 * guesses_per_second)
  
  puts PASTEL.dim("\n\n--- Analyse der Knack-Zeit ---")
  puts "Zeichenpool (N): #{pool}"
  puts "Passwortlänge (L): #{password.length}"
  puts "Angenommene Rate: #{guesses_per_second.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1,")} Versuche/Sek."
  
  puts "\n" + PASTEL.bold("Geschätzte Zeit zum Knacken: ") + PASTEL.bold.green(format_seconds(seconds_to_crack))
end

# --- FUNKTION 4: ASCII-TITEL GENERATOR (NEU) ---
def run_ascii_generator_ui
  puts PASTEL.yellow("--- ASCII-Titel Generator ---")
  print "Geben Sie einen Text ein: "
  text = gets.chomp
  text = "Ruby" if text.strip.empty?

  puts
  print_title(text) # Wiederverwendung der Titel-Funktion
end


# === HAUPTSCHLEIFE DES PROGRAMMS ===
loop do
  system("clear") || system("cls")
  print_title("Passwort Tool") # Haupttitel bei jedem Durchlauf anzeigen
  
  puts "Wählen Sie eine Option:"
  puts "  [1] Passwort-Stärke prüfen"
  puts "  [2] Sicheres Passwort generieren"
  puts "  [3] Zeit zum knacken berechnen"
  puts "  [4] Beenden"
  print "\nIhre Wahl: "
  
  choice = gets.chomp
  puts
  
  case choice
  when '1' then run_checker_ui
  when '2' then run_generator_ui
  when '3' then run_crack_time_ui
  when '4' then run_ascii_generator_ui # NEUER PUNKT
  when '5'
    puts PASTEL.cyan("Programm wird beendet. Bleib sicher!")
    break
  else
    puts PASTEL.red("Ungültige Auswahl. Bitte versuchen Sie es erneut.")
  end
  
  puts "\n\n" + PASTEL.dim("Drücken Sie Enter, um zum Hauptmenü zurückzukehren.")
  gets
end