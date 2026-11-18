# Lister: dai requisiti all'app Flutter

Questa lezione descrive come gli scenari richiesti sono stati tradotti in codice Flutter. I concetti principali sono composizione di widget, gestione dello stato, input dell'utente e navigazione tra schermate.

## Struttura del progetto

```text
lib/
├── main.dart
├── models/
│   └── activity.dart
├── screen/
│   ├── activity_list_screen.dart
│   └── add_activity_screen.dart
└── services/
    └── activity_storage.dart
```

`main.dart` avvia l'app e mostra `ActivityListScreen`. Il modello `Activity` rappresenta l'entità centrale del dominio:

- `id`: identifica univocamente l'attività;
- `title`: contiene il titolo obbligatorio;
- `isCompleted`: rappresenta lo stato *da fare* o *completata*;
- `isImportant`: indica se l'attività è importante.

Il modello è una normale classe Dart: contiene dati, ma non costruisce elementi grafici.

## S1 – Aggiungere un'attività

### Cosa è stato aggiunto

La schermata `AddActivityScreen` contiene:

- un campo per inserire il titolo;
- uno switch per indicare l'importanza;
- un pulsante per confermare;
- la validazione del titolo obbligatorio.

Il pulsante **Aggiungi attività** presente nell'elenco apre questa schermata. Se l'inserimento è valido, la nuova `Activity` viene restituita alla schermata precedente, aggiunta alla lista e viene mostrata una `SnackBar` di conferma.

Se l'utente torna indietro, non viene restituita alcuna attività: la lista rimane invariata e non compare la `SnackBar`.

### Concetti Flutter utilizzati

#### Input dell'utente

`TextFormField` raccoglie il titolo e `TextEditingController` consente di leggerne il valore. `SwitchListTile` gestisce il valore booleano dell'importanza.

#### Form e validazione

`Form` raggruppa i campi, mentre `GlobalKey<FormState>` permette di richiamare `validate()`. Il `validator` restituisce un messaggio quando il titolo è vuoto e `null` quando il valore è valido.

`AutovalidateMode.onUserInteraction` fa scomparire l'errore quando l'utente corregge il titolo.

#### Stato locale

`AddActivityScreen` è uno `StatefulWidget` perché il valore dello switch può cambiare. La chiamata a `setState()` aggiorna `_isImportant` e ricostruisce la parte interessata dell'interfaccia.

#### Navigazione tra schermate

`Navigator.push()` apre la schermata di inserimento. Alla conferma, `Navigator.pop(context, activity)` chiude la schermata e restituisce l'oggetto creato.

La schermata elenco usa `await` per attendere il risultato. Un risultato `null` indica che l'utente ha rinunciato.

## S2 – Consultare le attività

### Cosa è stato aggiunto

`ActivityListScreen` mostra:

- il numero di attività completate sul totale;
- titolo, stato e importanza di ogni attività;
- il pulsante per aggiungere una nuova attività;
- un indicatore di caricamento durante la lettura iniziale dei dati.

Quando la lista è vuota, il pulsante **Aggiungi attività** è il primo elemento mostrato sotto il conteggio e indica direttamente come iniziare.

### Concetti Flutter utilizzati

#### Composizione di widget

La schermata è costruita componendo widget più piccoli:

```text
Scaffold
├── AppBar
└── Column
    ├── Text del conteggio
    └── Expanded
        └── ListView
            ├── ListTile delle attività
            └── Pulsante Aggiungi attività
```

`Scaffold` fornisce la struttura generale, `Column` dispone gli elementi verticalmente, `Expanded` assegna alla lista lo spazio disponibile e `ListView` rende il contenuto scorrevole.

Ogni `ListTile` mostra una stella, il titolo, lo stato, uno switch e il cestino.

#### Stato della schermata

La lista `_activities` appartiene allo `State` di `ActivityListScreen`. Quando la lista cambia, `setState()` richiede a Flutter una nuova esecuzione di `build()`.

Il conteggio non viene salvato in una seconda variabile. Viene calcolato filtrando le attività con `isCompleted == true`, evitando stati duplicati che potrebbero diventare incoerenti.

#### Identità dei widget

Ogni riga usa una `ValueKey` basata sull'ID dell'attività. In questo modo Flutter può distinguere correttamente anche due attività con lo stesso titolo.

## S3 – Aggiornare lo stato

### Cosa è stato aggiunto

Ogni attività presenta uno `Switch`:

- disattivato: stato **Da fare**;
- attivato e verde: stato **Completata**.

Il titolo di un'attività completata viene barrato. Anche la stella è interattiva e permette di modificare immediatamente l'importanza.

### Concetti Flutter utilizzati

#### Eventi e callback

La proprietà `onChanged` dello switch riceve il nuovo valore booleano. `onPressed` della stella esegue invece una funzione quando l'icona viene premuta.

#### Aggiornamento reattivo con `setState()`

La callback modifica `isCompleted` o `isImportant` dentro `setState()`. Flutter riesegue `build()` e aggiorna subito:

- posizione e colore dello switch;
- testo dello stato;
- decorazione del titolo;
- stella;
- conteggio completate/totale.

Non è necessaria una schermata di dettaglio perché tutte le modifiche previste avvengono direttamente nell'elenco.

## S4 – Eliminare un'attività

### Cosa è stato aggiunto

Ogni riga contiene un'icona a forma di cestino. La pressione apre un dialogo che mostra il titolo dell'attività e chiede conferma.

Il dialogo presenta verticalmente:

- **Elimina**, come azione distruttiva;
- **Annulla**, per rinunciare.

Lo sfondo viene sfocato tramite `BackdropFilter`.

### Concetti Flutter utilizzati

#### Dialoghi e risultato asincrono

`showDialog<bool>()` apre il dialogo e restituisce in modo asincrono:

- `true` quando l'utente conferma;
- `false` quando preme **Annulla**;
- `null` quando chiude il dialogo in un altro modo.

I pulsanti chiudono il dialogo usando `Navigator.pop()` e passano il risultato scelto.

#### Eliminazione tramite ID

Dopo la conferma, `removeWhere()` elimina l'elemento con l'ID corrispondente. L'ID evita di rimuovere l'attività sbagliata quando esistono titoli uguali.

La rimozione avviene dentro `setState()`, quindi lista e conteggio vengono aggiornati insieme. In caso di annullamento non viene eseguita alcuna modifica.

## Persistenza locale – estensione oltre lo scope principale

La traccia non richiede esplicitamente un sistema di persistenza, ma la frase relativa all'avvio dell'app può suggerire che le attività create debbano essere ancora disponibili dopo la chiusura.

Per questo è stato aggiunto `ActivityStorage`, separando la logica di salvataggio dall'interfaccia. Questa scelta applica la **separazione delle responsabilità**:

- `Activity` rappresenta i dati;
- `ActivityListScreen` mostra e modifica lo stato;
- `ActivityStorage` salva e carica la lista.

### Serializzazione JSON

`Activity.toJson()` converte un oggetto in una mappa. `Activity.fromJson()` esegue l'operazione inversa. La lista di mappe viene trasformata in una stringa JSON con `jsonEncode()` e ricostruita con `jsonDecode()`.

### `shared_preferences`

`SharedPreferencesAsync` salva la stringa JSON nella memoria locale del dispositivo associandola alla chiave `activities`.

Il caricamento parte da `initState()`, cioè quando viene creato lo stato della schermata. Poiché l'accesso alla memoria è asincrono, durante l'attesa viene mostrato un `CircularProgressIndicator`.

La lista viene salvata nuovamente dopo:

- aggiunta;
- cambio dello stato;
- cambio dell'importanza;
- eliminazione.

Questa persistenza è locale: non sincronizza i dati tra dispositivi e viene rimossa con la disinstallazione dell'app.

## `activity_test` – estensione oltre lo scope principale

La traccia non richiede test automatici, ma `activity_test.dart` verifica il comportamento fondamentale della serializzazione.

Il test segue tre passaggi:

1. crea un'`Activity` con valori noti;
2. la converte in JSON e la ricostruisce;
3. controlla che ID, titolo, stato e importanza non siano cambiati.

Questo è un **unit test**: controlla una piccola unità di codice senza avviare l'intera interfaccia Flutter. Il comando `flutter test` esegue il test e segnala eventuali regressioni nella conversione dei dati.

Il test non sostituisce le prove manuali richieste su emulatore e smartphone, ma aggiunge un controllo ripetibile sulla parte dati dell'app.
