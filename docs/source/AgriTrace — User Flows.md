# AgriTrace — User Flows

Oct 29, 2026 · @Sathya

## Design rules

Many farmers will be using a smartphone app for the first time, so every farmer screen asks for one thing, shows it as a picture, speaks it aloud in Tamil, and needs no typing. Any routine farm event takes three taps. These rules apply to every farmer screen; the field officer and FPO screens follow them where they can.

- **One job per screen.** The home screen shows the farmer's next task as one big card; everything else is one tap away.
- **Pictures and voice before words.** Every button has an icon, a short word in the farmer's language, and a speaker icon that plays a recorded voice prompt. Recorded Tamil voices are used rather than robotic text-to-speech.
- **Tap, never type.** Quantities use large + / − buttons or a number pad; choices are picture cards. Farmers never see a free-text box.
- **The photo is the proof.** Where a photo is needed the camera opens by itself; location and time are recorded silently with it. Gallery uploads are not allowed.
- **Three taps for routine events:** choose the event, take the photo, confirm.
- **Big targets.** Buttons are at least 56 dp tall and full width with wide gaps, reachable with one thumb.
- **Colour plus shape, never colour alone.** Green tick = done, orange circle = to do, red triangle = needs attention.
- **Works with no signal.** Entries save instantly on the phone and send when signal returns; a small cloud icon shows "waiting to send".
- **Mistakes are easy to undo.** A confirm screen shows the photo before saving, and farmers can undo an entry for 24 hours. Farmers cannot delete; the field officer can correct.
- **Language first.** Tamil by default for Tamil Nadu FPOs, switched with one button. Dates read "14 Feb", not "2026-02-14"; numbers use Indian grouping (1,20,000).
- **Log in once.** Phone number plus a one-time SMS code at setup; the app stays signed in. No passwords.
- **Help is a person.** A "Call my field officer" button is on every screen, and the field officer can do anything on the farmer's behalf.
- **Built for basic 4G phones.** Runs on Android Go phones with 2 GB memory, app under 30 MB. Entries send within seconds of saving, and photos are compressed to about 300 KB so each uploads in a second or two even on a weak 4G signal. The offline queue still covers dead zones in fields and godowns.

## Who uses what

There is one mobile app with different home screens per role, plus a web portal for office work and a public page for buyers. A farmer only ever sees the farmer screens.

| User | Device | App / screen | What they do |
| --- | --- | --- | --- |
| Farmer | Basic Android phone, often shared with family | Mobile app — farmer mode | Log farm events with a photo; see what to do next; see payments and benefits |
| Field officer | Android phone | Mobile app — field officer mode | Onboard farmers; log events for farmers without phones; clear flags; carry the moisture meter |
| QC / grading officer | Android tablet or phone at the processing unit | Mobile app — QC mode | Record intake moisture, grading readings and lab results |
| FPO admin | Laptop / desktop | Web portal | Approve members, create batches, approve grading, publish pages, see reports |
| Farmer without a smartphone | Feature phone | Missed-call voice line and SMS | Hear reminders and payment alerts; the field officer logs events for them |
| Buyer or consumer | Any phone | Public QR page (no login) | Scan the pack and see the farm-to-pack story |

## Farmer home screen

&#91;embedded content: farmer home screen · wireframe\]

The farmer's whole app is this one screen: the card at the top always holds the single most useful next step, and the four buttons cover everything else. A wireframe, not final visual design.

## Onboarding a farmer

The field officer onboards each farmer in person, on the farm, in about 10 minutes; the farmer never fills a form alone. The officer drives the screens, and the farmer only listens, agrees, and stands in the field for the location.

1. **Start:** the officer taps "Add farmer" and enters the farmer's mobile number. The farmer gets an SMS code, which the app reads automatically.
2. **Consent:** the app plays a short recorded message in Tamil explaining what is collected and why. The farmer taps a large "I agree" button; the consent is saved with time and the officer's name.
3. **Who:** the officer takes the farmer's photo and enters the name. Language is picked from flag buttons.
4. **Location:** at the plot, the screen shows one big green button, "I am standing in my field". A circle fills as the GPS gets accurate; when it turns green, the pin saves. No map, no typing.
5. **Land size:** a large + / − stepper in acres or cents (100 cents = 1 acre), whichever the farmer uses. The officer adds the survey number if the farmer has it.
6. **Walk the boundary (optional):** tap "Start walking", walk the edge, tap "Stop". The app draws the shape and shows the area next to the declared size.
7. **Water and practice:** picture cards — well, borewell, canal, tank, rain only.
8. **Crop:** picture cards of the crops the FPO handles. The GI-region check runs instantly and shows a green tick or an orange "needs review" circle.
9. **Farmer's phone:** the officer installs the app on the farmer's phone (or the farmer scans a QR), signs in with the same SMS code, and plays the 60-second voice tour. The farmer's first task card appears on the home screen.

If the farmer has no smartphone, the officer stops after step 8 and the farmer is set up for voice calls and SMS instead.

## Logging a farm event

&#91;embedded content: logging a farm event · 3 taps, 1 optional choice\]

The farmer never types: the confirm screen reads the entry aloud ("Harvest, 6 bags, today — correct?") and offers only a big tick or Retake. Events that need a product or a quantity add one picture or + / − screen between the first two taps.

## Each farm event

Every event follows the same three taps; the only difference is the one extra choice some events need, and the app fills in everything it can by itself.

| Event | Extra choice the farmer makes | What the app fills in by itself |
| --- | --- | --- |
| Land preparation | None — photo of the ploughed field | Date, GPS, plot and area from onboarding |
| Nursery | Tap the seed variety from pictures (or photograph the seed packet) | Date, GPS |
| Sowing / transplanting | None — photo of the planted field; "Again" button for a second round | Date, GPS, seed variety from nursery |
| Fertiliser or pesticide | Tap the product from pictures of what the FPO stocks; number of bags with + / − | Kilograms (bags × bag size), product category, practice tag (organic / inorganic), date, GPS |
| Harvest | Number of bags with + / − | Kilograms, date, GPS, yield check against the plot's ceiling |
| Drying | "Start drying" with a photo; days later, "Drying done" with a photo | Start and end dates; reminder to finish; moisture reading added by the field officer's meter |
| Packing | Number of bags with + / − and a photo of the bags | Kilograms, date, GPS; lot becomes "Ready to sell" |
| Problem (pest, disease, rain damage) | Photo plus a 30-second voice note | Date, GPS; alert to the field officer |

When a farmer opens an event out of order — say harvest before sowing — the app does not block it; it asks once by voice "Did you already sow?" with Yes / No buttons, and flags the gap for the field officer.

## Selling to the FPO

At the collection centre the farmer shows a QR code on their phone and the FPO staff scan it; the farmer does nothing else. Farmers without a smartphone give their mobile number instead.

1. **Farmer:** taps the green "Sell" button on the home screen. The phone shows a large QR code for the lot that is ready to sell.
2. **FPO staff:** scans the QR with the QC app. The lot, farmer and packed quantity appear.
3. **FPO staff:** weighs the bags and enters the weight; the field officer or QC officer takes an intake moisture reading.
4. **Checks run on the spot:** weight vs. packed quantity, yield ceiling, moisture limit. A green tick means accepted; an orange circle explains the problem in one line.
5. **Farmer:** hears and sees a confirmation — "200 kg received, 14 Mar" — and gets the same as an SMS. Payment status appears later on the farmer's "Money" screen.

## Field officer flows

The field officer's home screen is a to-do list sorted by village, so a day's visits can be planned in one look.

**Home screen sections**

- **Today's visits:** farmers with an event due, grouped by village.
- **Flags to clear:** orange and red items — event logged off the plot, yield above the warning margin, a missing photo, an out-of-order event, a problem report with a voice note.
- **Farmers without phones:** a list of farmers whose events the officer logs in person.

**Assist mode (logging for a farmer)**

1. Tap the farmer's name (or scan the QR on the farmer's ID card).
2. The screen switches to that farmer's home screen, with a coloured bar across the top reading "Logging for: \[farmer name\]" so it is never confused with the officer's own account.
3. Log the event exactly as the farmer would. The record shows "entered by field officer" and the officer's GPS; if the officer is not on the plot, it is marked "entered remotely".

**Clearing a flag**

1. Open the flag; it shows what triggered it, the photo and a map.
2. Choose one of three buttons: "Looks fine", "Fix it" (correct the entry), or "Escalate to FPO admin".
3. Add a reason from a short picture list or a voice note; the flag closes and the log keeps the reason.

## FPO admin and QC flows

Office users get more detail, but each task is still a single guided path ending in one approve button, and the system blocks approval with a plain-language reason when a rule fails.

**Create a batch (FPO admin, web portal)**

1. Open "Ready lots" — received lots with green ticks, filtered by crop.
2. Tick the lots to combine; the running total and each farmer's share (%) update as you tick.
3. Lots outside the GI region or held by the yield check show greyed out with the reason; they can go into a non-GI batch.
4. Tap "Create batch" — a batch ID and QR are generated.

**Grade a batch (QC officer, mobile app)**

1. Scan the batch QR.
2. The app shows only the readings this crop's standard needs (e.g. for dry chilli: moisture, extraneous matter, broken pods, colour). Enter each with a number pad, or pair the moisture meter by Bluetooth.
3. The app calculates the grade and shows it in large type with the standard it used. Upload a lab report photo if there is one.

**Approve and publish (FPO admin)**

1. Open the batch; one screen shows grade, readings, any warnings and the public page preview.
2. Tap "Approve grading", then "Publish". If the declared grade is above the calculated grade, or a required reading is missing, the button stays grey with the reason underneath.
3. Download QR labels for printing.

## Alerts, help and feature phones

Farmers hear about things the way they already get news — a phone notification with sound, an SMS, or WhatsApp — and every message tells them one thing to do.

- **Reminders:** "Time to log your harvest" with a voice clip, sent from the crop calendar. One tap on the notification opens the right event.
- **Results:** sale received, grade given, payment made, benefit credited — each as a short voice + text notification and an SMS.
- **Storage alerts** (from the storage probes) go to the field officer and FPO admin, not the farmer.
- **Help:** a "Call my field officer" button on every screen dials directly. A 60-second voice tour can be replayed from the menu.
- **Feature-phone farmers:** a missed call to the FPO's number triggers a call back with recorded voice messages — next task, last sale, payment status — in Tamil. The same updates arrive as SMS. Their field officer logs their farm events in assist mode.
- **Language:** every message, voice clip and SMS goes out in the farmer's chosen language.

## When things go wrong

The app never shows an error code; every problem appears as one picture, one short sentence read aloud, and one button that fixes it.

| Situation | What the farmer sees and hears | What happens behind the scenes |
| --- | --- | --- |
| No signal | Entry saves with a green tick and a small grey cloud: "Saved. Will send when signal comes." | Queued on the phone; sent automatically, oldest first |
| Weak GPS | A filling circle: "Hold the phone up, finding your location". After 60 seconds, "Save anyway" | Saved with its accuracy; low accuracy is flagged for the field officer |
| Event far from the plot | Nothing blocks the farmer | Flag sent to the field officer |
| Photo too dark or blurry | "Photo is not clear. Take again?" with a big camera button | Basic brightness and blur check on the phone before saving |
| Wrong entry | "Undo" button on the entry for 24 hours | After 24 hours only the field officer can correct, with a reason |
| Phone lost or changed | Sign in on the new phone with the same number and SMS code | All synced history returns; unsent entries on the old phone are lost, so the cloud icon reminds farmers to get signal |
| Low storage on phone | "Phone is full. Send your entries now?" | Photos already sent are cleared from the phone automatically |
| App update needed | Updates install quietly in the background | Old app versions keep working for at least one season |
