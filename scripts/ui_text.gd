class_name UIText
extends RefCounted

const MENU_TITLE := "ui.menu.title"
const MENU_SUBTITLE := "ui.menu.subtitle"
const MENU_START := "ui.menu.start"
const MENU_CONTINUE := "ui.menu.continue"
const MENU_SETTINGS := "ui.menu.settings"
const MENU_EXIT := "ui.menu.exit"
const MENU_SETTINGS_TITLE := "ui.menu.settings.title"
const MENU_SETTINGS_BODY := "ui.menu.settings.body"
const MENU_BACK := "ui.menu.back"
const MENU_BGM := "ui.menu.settings.bgm"
const MENU_SFX := "ui.menu.settings.sfx"
const MENU_DREAM_START_TITLE := "ui.menu.dream.start.title"
const MENU_DREAM_START_BODY := "ui.menu.dream.start.body"
const MENU_DREAM_CONTINUE_TITLE := "ui.menu.dream.continue.title"
const MENU_DREAM_CONTINUE_BODY := "ui.menu.dream.continue.body"

const DIALOGUE_DEFAULT_CHAPTER := "ui.dialogue.default.chapter"
const DIALOGUE_DEFAULT_SPEAKER := "ui.dialogue.default.speaker"
const DIALOGUE_DEFAULT_BODY := "ui.dialogue.default.body"
const DIALOGUE_CONTINUE := "ui.dialogue.continue"

const DECISION_DEFAULT_CHAPTER := "ui.decision.default.chapter"
const DECISION_DEFAULT_TITLE := "ui.decision.default.title"
const DECISION_DEFAULT_PROMPT := "ui.decision.default.prompt"
const DECISION_ARDA_NAME := "ui.decision.arda.name"
const DECISION_EDA_NAME := "ui.decision.eda.name"
const DECISION_ARDA_HINT := "ui.decision.arda.hint"
const DECISION_EDA_HINT := "ui.decision.eda.hint"
const DECISION_OPTION_ARDA := "ui.decision.option.arda"
const DECISION_OPTION_EDA := "ui.decision.option.eda"

const INFO_DEFAULT_TAG := "ui.info.default.tag"
const INFO_DEFAULT_TITLE := "ui.info.default.title"
const INFO_DEFAULT_BODY := "ui.info.default.body"
const INFO_DEFAULT_REWARD := "ui.info.default.reward"
const INFO_BACK := "ui.info.back"
const INFO_CONTINUE := "ui.info.continue"

static func text(key: String, fallback: String) -> String:
	var translated := TranslationServer.translate(key)
	if translated.is_empty() or translated == key:
		return fallback
	return translated