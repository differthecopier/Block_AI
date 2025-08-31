# AI Fortress - Nieodwracalna Blokada AI dla Arch Linux

**⚠️ OSTRZEŻENIE ⚠️**

Ten projekt jest przeznaczony do stworzenia **celowo trudnej do usunięcia** blokady usług AI na systemie Arch Linux. Nie posiada prostego skryptu deinstalacyjnego. Usunięcie blokady wymaga ręcznego, wieloetapowego procesu opisanego w sekcji "Procedura Awaryjna". Używasz tego na własną odpowiedzialność.

## Filozofia

Celem tego projektu nie jest stworzenie blokady, której nie da się obejść. Zawsze istnieje możliwość uruchomienia systemu z Live USB. Celem jest zbudowanie **fortecy z tak wysokimi murami i tak skutecznymi mechanizmami obronnymi**, że impulsywne próby jej sforsowania zakończą się porażką i frustracją. To narzędzie ma wspierać Twoją determinację, a nie ją zastępować.

## Jak to działa? (Architektura Fortecy)

Forteca opiera się na trzech warstwach obrony, które wzajemnie się wspierają:

1.  **Mur Obronny (`/etc/hosts`):** Podstawowa, niezwykle skuteczna blokada na poziomie DNS. Wszystkie znane domeny AI są przekierowywane donikąd, co uniemożliwia nawiązanie połączenia.
2.  **Wzmocniona Brama (`chattr +i`):** Plik `/etc/hosts` zostaje oznaczony jako "niezmienialny" (immutable). Nawet administrator (`root`) nie może go zmodyfikować ani usunąć bez uprzedniego zdjęcia tej flagi.
3.  **Nieustanny Strażnik (Demon `systemd`):** W tle działa lekki, ukryty pod mylącą nazwą demon. Co kilka sekund sprawdza:
    *   Czy flaga `+i` na pliku `/etc/hosts` jest wciąż aktywna. Jeśli nie, natychmiast ją przywraca.
    *   Czy on sam (jego własna usługa `systemd`) nie został wyłączony lub zamaskowany. Jeśli tak, natychmiast się reaktywuje.

To tworzy pętlę samonaprawiającą, która aktywnie zwalcza próby sabotażu.

## Instalacja

1.  **Sklonuj lub pobierz to repozytorium:**
    ```bash
    git clone [adres-twojego-prywatnego-repozytorium]
    cd ai-fortress
    ```

2.  **(Opcjonalnie) Dostosuj listę blokowanych domen:**
    Otwórz plik `install.sh` w edytorze tekstu i zmodyfikuj listę `AI_DOMAINS`, aby dodać lub usunąć domeny.

3.  **Uruchom skrypt instalacyjny z uprawnieniami roota:**
    *Nadaj skryptowi uprawnienia do wykonania, a następnie go uruchom.*
    ```bash
    chmod +x install.sh
    sudo ./install.sh
    ```
    Skrypt zainstaluje blokadę, aktywuje strażnika i zakończy działanie. Twoja forteca jest gotowa.

## Odpowiedź na pytanie: Czy można zablokować również samo IP?

**Krótka odpowiedź:** Tak, ale jest to bardzo zły pomysł i w praktyce nieskuteczne.

**Długa odpowiedź:**
Blokowanie adresów IP za pomocą firewalla (np. `iptables` lub `nftables`) wydaje się logicznym kolejnym krokiem, ale ma fundamentalne wady w przypadku dużych usług chmurowych:

1.  **Dynamiczne i liczne adresy IP:** Usługi takie jak OpenAI czy Google AI nie działają pod jednym, stałym adresem IP. Korzystają z ogromnych pul adresów dostarczanych przez platformy chmurowe (AWS, Azure, Google Cloud). Te adresy ciągle się zmieniają.
2.  **Ryzyko "szkód ubocznych":** Próbując zablokować całą pulę adresów IP używaną przez OpenAI, możesz przypadkowo zablokować tysiące innych, niewinnych stron i usług, które również korzystają z tej samej chmury.
3.  **Koszmar utrzymania:** Utrzymywanie aktualnej listy adresów IP do zablokowania jest praktycznie niemożliwe.

**Wniosek:** Blokada na poziomie DNS (przez `/etc/hosts`) jest o wiele bardziej niezawodna, stabilna i precyzyjna dla tego konkretnego celu. Skupiamy się na niej w 100%.

