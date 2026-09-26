.pragma library

// Qt.locale().name supplies the system locale (for example, pt_BR).
// Regional variants share a language; unsupported locales fall back to English.
var messages = {
  en: ["WORKSPACES IN USE", "No workspaces with open windows", "navigate", "open", "close"],
  pt: ["WORKSPACES EM USO", "Nenhum workspace com janelas abertas", "navegar", "abrir", "fechar"],
  es: ["ESPACIOS DE TRABAJO EN USO", "No hay espacios de trabajo con ventanas abiertas", "navegar", "abrir", "cerrar"],
  fr: ["ESPACES DE TRAVAIL UTILISÉS", "Aucun espace de travail avec des fenêtres ouvertes", "naviguer", "ouvrir", "fermer"],
  de: ["BELEGTE ARBEITSFLÄCHEN", "Keine Arbeitsflächen mit offenen Fenstern", "navigieren", "öffnen", "schließen"],
  it: ["SPAZI DI LAVORO IN USO", "Nessuno spazio di lavoro con finestre aperte", "navigare", "aprire", "chiudere"],
  nl: ["WERKBLADEN IN GEBRUIK", "Geen werkbladen met open vensters", "navigeren", "openen", "sluiten"],
  pl: ["UŻYWANE OBSZARY ROBOCZE", "Brak obszarów roboczych z otwartymi oknami", "nawigacja", "otwórz", "zamknij"],
  ru: ["ИСПОЛЬЗУЕМЫЕ РАБОЧИЕ СТОЛЫ", "Нет рабочих столов с открытыми окнами", "навигация", "открыть", "закрыть"],
  uk: ["ВИКОРИСТОВУВАНІ РОБОЧІ СТОЛИ", "Немає робочих столів із відкритими вікнами", "навігація", "відкрити", "закрити"],
  tr: ["KULLANILAN ÇALIŞMA ALANLARI", "Açık penceresi olan çalışma alanı yok", "gezin", "aç", "kapat"],
  ja: ["使用中のワークスペース", "ウィンドウが開いているワークスペースはありません", "移動", "開く", "閉じる"],
  ko: ["사용 중인 작업 공간", "열린 창이 있는 작업 공간이 없습니다", "이동", "열기", "닫기"],
  zh: ["使用中的工作区", "没有包含打开窗口的工作区", "导航", "打开", "关闭"],
  zh_Hant: ["使用中的工作區", "沒有包含開啟視窗的工作區", "導覽", "開啟", "關閉"],
  ar: ["مساحات العمل المستخدمة", "لا توجد مساحات عمل بها نوافذ مفتوحة", "تنقّل", "افتح", "أغلق"],
  hi: ["उपयोग में कार्यस्थान", "खुली विंडो वाला कोई कार्यस्थान नहीं है", "नेविगेट करें", "खोलें", "बंद करें"]
}

function forLocale(localeName) {
  var parts = String(localeName || "").replace(/\..*$/, "").replace(/@.*$/, "").replace(/-/g, "_").toLowerCase().split("_")
  var language = parts[0]
  var traditionalChinese = language === "zh"
    && (parts.indexOf("hant") >= 0 || (parts.indexOf("hans") < 0
      && (parts.indexOf("tw") >= 0 || parts.indexOf("hk") >= 0 || parts.indexOf("mo") >= 0)))
  var entry = messages[traditionalChinese ? "zh_Hant" : language] || messages.en
  return {
    title: entry[0],
    empty: entry[1],
    help: "← → / Tab: " + entry[2] + "  ·  Enter: " + entry[3] + "  ·  Esc: " + entry[4]
  }
}
