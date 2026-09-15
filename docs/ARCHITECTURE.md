# ÚLTIMO ACESSO — Arquitetura Técnica

**Slogan:** *Algumas pessoas deixam mensagens. Outras deixam pistas.*

**SO fictício:** OSIS · **Dispositivo:** VANTA

## Decisões arquiteturais

1. **Flutter** — UI fluida cross-platform (Android/iOS/Web), animações nativas, arquitetura escalável.
2. **Conteúdo data-driven (JSON)** — Casos em `assets/cases/case_XXX/` separados do motor. Novos casos = novos JSON, zero rewrite do engine.
3. **Clean / modular** — `domain` (modelos + engines), `data` (load/save), `presentation` (UI OSIS + apps).
4. **Provider** — Estado reativo do progresso, telefone e notificações sem over-engineering.
5. **O celular é o jogo** — Sem HUD externo. Pause/settings via `Configurações → Sistema → Jogo`.

## Fluxo do jogo

```
Intro cinematográfica → Lock Screen → (PIN) → Home OSIS
  → Explorar apps → Descobrir pistas → Quadro / Timeline
  → Desbloqueios por combinação → Eventos live / remote access
  → Acusação → Finais A–E → Save automático
```

## Sistemas

| Sistema | Responsabilidade |
|---------|------------------|
| GameEngine | Orquestra progresso, score, decisões |
| ClueEngine | Descoberta, relações, unlocks |
| NarrativeEngine | Eventos timed, reviravoltas, finais |
| NotificationEngine | Push in-game, pistas temporárias |
| SaveService | Persistência local automática |
| PhoneController | Shell OSIS, apps, Dynamic Island, CC |

## Escalabilidade de casos

```
assets/cases/case_001/case.json
assets/cases/case_002/case.json  ← futuro, sem mudar motor
```

Cada caso declara: characters, clues, conversations, photos, calls, emails, notes, files, locations, browserHistory, timeline, endings, unlockRules, liveEvents, contradictions, puzzles.
