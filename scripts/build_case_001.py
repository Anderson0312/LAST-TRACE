#!/usr/bin/env python3
"""Gera assets/cases/case_001/case.json — caso solo jogável."""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "cases" / "case_001" / "case.json"


def clue(cid, name, typ, desc, content, origin, importance="medium", state="hidden", **kw):
    item = {
        "id": cid,
        "name": name,
        "type": typ,
        "description": desc,
        "content": content,
        "origin": origin,
        "importance": importance,
        "initialState": state,
    }
    item.update(kw)
    return item


def msg(mid, sender, body, ts, **kw):
    item = {
        "id": mid,
        "senderId": sender,
        "kind": kw.pop("kind", "text"),
        "body": body,
        "timestamp": ts,
    }
    item.update(kw)
    return item


def conv(cid, contact, name, messages, unread=False, reveals=None):
    item = {
        "id": cid,
        "contactId": contact,
        "displayName": name,
        "unread": unread,
        "messages": messages,
    }
    if reveals:
        item["revealsClueIds"] = reveals
    return item


characters = [
    {"id": "char_marina", "name": "Marina Alves", "age": 27, "profession": "Jornalista investigativa", "relationToVictim": "Vítima", "role": "victim", "initialSuspicion": 0, "personality": "Obstinada", "secrets": ["Investigava contrato Aurora"]},
    {"id": "char_rafael", "name": "Rafael Mendes", "age": 30, "profession": "Designer", "relationToVictim": "Ex-namorado", "role": "suspect", "initialSuspicion": 55, "personality": "Ciumento", "alibi": "Diz que estava no Lume", "secrets": ["Rastreava o celular dela"]},
    {"id": "char_daniel", "name": "Daniel Rocha", "age": 38, "profession": "Editor-chefe", "relationToVictim": "Chefe", "role": "suspect", "initialSuspicion": 48, "personality": "Cínico", "secrets": ["Recebeu 80 mil da AV Services"]},
    {"id": "char_camila", "name": "Camila Duarte", "age": 29, "profession": "Editora assistente", "relationToVictim": "Colega de redação", "role": "suspect", "initialSuspicion": 35, "personality": "Ansiosa", "secrets": ["Marcou o encontro no São Lucas"]},
    {"id": "char_bruno", "name": "Bruno Vale", "age": 44, "profession": "Empresário ValeLogística", "relationToVictim": "Alvo da pauta Aurora", "role": "suspect", "initialSuspicion": 40, "personality": "Controlador", "alibi": "Reunião noturna", "secrets": ["Linha 1717", "Mandou Camila ao pilar B"]},
    {"id": "char_rita", "name": "Rita Okamoto", "age": 34, "profession": "Analista ValeLog", "relationToVictim": "Fonte anônima R.", "role": "mysterious", "initialSuspicion": 15, "personality": "Discreta", "secrets": ["Vazou as planilhas Aurora"]},
    {"id": "char_leo", "name": "Leonardo Pires", "age": 41, "profession": "Segurança São Lucas", "relationToVictim": "Testemunha", "role": "witness", "initialSuspicion": 8, "personality": "Cauteloso", "secrets": ["Câmera do pilar B apagada"]},
    {"id": "char_sofia", "name": "Sofia Alves", "age": 58, "profession": "Aposentada", "relationToVictim": "Mãe", "role": "witness", "initialSuspicion": 0, "personality": "Protetora", "secrets": []},
    {"id": "char_unknown", "name": "Não atender", "age": None, "profession": None, "relationToVictim": "Linha 1717", "role": "mysterious", "initialSuspicion": 20, "personality": "Silêncio", "secrets": ["Pré-pago de Bruno"]},
]

clues = [
    clue("CLUE_LOCK_OPEN", "Dispositivo desbloqueado", "system", "Acesso ao VANTA", "O aparelho de Marina foi liberado.", "OSIS", "low"),
    clue("CLUE_LAST_MSG", "Eu descobri quem está por trás disso", "message", "Última mensagem", "Marina enviou a frase e sumiu.", "WhatsApp", "critical"),
    clue("CLUE_RAFAEL_WHERE", "Rafael no Lume", "message", "Álibi", "Rafael insiste que estava no bar Lume às 23h.", "WhatsApp · Rafael", "high"),
    clue("CLUE_MSG_DELETED", "Mensagem apagada", "message", "Recuperada", "Fragmento: 'não vá ao estacionamento sozinha'.", "WhatsApp", "critical"),
    clue("CLUE_PARKING", "Aparelho no São Lucas", "location", "Local do achado", "VANTA encontrado no Estacionamento São Lucas, pilar B.", "Mapas / Ajustes", "critical"),
    clue("CLUE_LOC_OFF", "Localização desligada", "system", "Ajustes", "GPS desligado às 23:28. Último ponto: São Lucas.", "Ajustes", "high"),
    clue("CLUE_LOC_RESTAURANT", "Jantar no Lume", "location", "Histórico", "Marina esteve no Lume às 22:10 — não sozinha.", "Mapas", "medium"),
    clue("CLUE_CALL_UNKNOWN", "Ligação 23:41 — desconhecido", "call", "Pré-pago", "Chamada de +55 11 90000-1717. 41s. Sem identificação.", "Telefone", "critical"),
    clue("CLUE_CALL_DANIEL", "Daniel liga às 21:02", "call", "Chefe", "Daniel cobra a pauta e pede para 'segurar'.", "Telefone", "medium"),
    clue("CLUE_VOICEMAIL", "Correio de Camila", "audio", "Desculpa", "Camila: 'Desculpa. Eu não tinha escolha. Não vá.'", "Correio de voz", "critical"),
    clue("CLUE_NOTE_IF", "Se alguma coisa acontecer comigo", "note", "Nota", "Marina deixou instruções para abrir a pasta Aurora.", "Notas", "critical"),
    clue("CLUE_NOTE_R", "Lembrete: R. = RO", "note", "Identidade", "R. não é Rafael. Iniciais RO.", "Notas", "high"),
    clue("CLUE_R_THREAD", "Contato R.", "message", "Fonte", "Thread curta com R. sobre planilhas.", "Contatos / WhatsApp", "high"),
    clue("CLUE_EMAIL_RITA", "E-mail de Rita", "email", "Confirmação", "Rita Okamoto pede para Marina apagar o rastro.", "Mail", "high"),
    clue("CLUE_R_IDENTITY", "R. é Rita Okamoto", "contradiction", "Reviravolta", "R. = Rita Okamoto, analista da ValeLog.", "Quadro", "critical"),
    clue("CLUE_EMAIL_DANIEL", "Segura a matéria", "email", "Pressão", "Daniel: a pauta Aurora não sobe.", "Mail", "high"),
    clue("CLUE_FILE_AURORA", "Pasta Aurora", "file", "Contrato", "Planilha de superfaturamento ValeLog × prefeitura.", "Arquivos", "critical"),
    clue("CLUE_CONTRACT_AURORA", "Contrato Aurora", "file", "PDF", "Cláusula 17: frota fantasma. Assinatura B. Vale.", "Arquivos", "critical"),
    clue("CLUE_PHOTO_PLATE", "Placa parcial", "photo", "Hotspot", "SUV preto, placa NEX-4A??, adesivo ValeLog.", "Fotos", "high"),
    clue("CLUE_PHOTO_REFLECTION", "Reflexo de Camila", "photo", "Hotspot", "No vidro do Lume, Camila observa Marina.", "Fotos", "high"),
    clue("CLUE_META_MISMATCH", "EXIF adulterado", "metadata", "Metadados", "Foto do estacionamento com hora 21:00; GPS 23:33.", "Fotos", "medium"),
    clue("CLUE_REMOTE_ACCESS", "Acesso remoto", "system", "OSIS", "Sessão ativa via proxy AV Services.", "Ajustes", "critical"),
    clue("CLUE_FILE_DAT", "arquivo_00017.dat", "file", "Oculto", "Dump com timestamp 23:47 — última carga.", "Arquivos", "high"),
    clue("CLUE_CAL_EVENT", "Agenda 23:30", "timeline", "Calendário", "Encontro 'pauta' no São Lucas às 23:30.", "Calendário", "high"),
    clue("CLUE_RECOVERED_FRAGMENT", "Backup Pulse", "file", "Lixeira", "Fragmento recuperado: 'Camila marcou. Não confia.'", "Lixeira", "medium"),
    clue("CLUE_AUDIO_THREAT", "Ameaça gravada", "audio", "Ditafone", "'Você não deveria estar olhando isso.'", "Ditafone", "high"),
    clue("CLUE_DANIEL_MONEY", "R$ 80.000 AV Services", "file", "Pix", "Comprovante para D. Rocha — AV Services.", "Nubank", "high"),
    clue("CLUE_BRUNO_PRESSURE", "Pressão de Bruno", "message", "WhatsApp", "Bruno: reunião falsa. 'Cuide da jornalista.'", "WhatsApp", "critical"),
    clue("CLUE_BROWSER_LOC", "Busca estacionamento", "browser", "Safari", "Marina buscou 'Estacionamento São Lucas pilar B'.", "Safari", "medium"),
    clue("CLUE_SOFIA_CALL", "Ligação da mãe 22:05", "call", "Família", "Sofia pede para Marina ir para casa.", "Telefone", "low"),
    clue("CLUE_LEO_CAMERA", "Câmera apagada", "email", "Segurança", "Leo admite que o DVR do pilar B falhou 'por ordem'.", "Mail", "high"),
    clue("CLUE_UNKNOWN_1717", "Linha 1717", "call", "Pré-pago", "O número 1717 aparece em Bruno e no desconhecido.", "Telefone", "high"),
    clue("CLUE_AURORA_SHEETS", "Planilhas vazadas", "file", "xlsx", "Abas: frota fantasma, propina, AV Services.", "Arquivos", "high"),
    clue("CLUE_CAMILA_LURE", "Camila atraiu Marina", "contradiction", "Isca", "Camila marcou o São Lucas sob pressão.", "Quadro", "critical"),
    clue("CLUE_BRUNO_CAR", "Carro de Bruno no local", "photo", "Placa", "Frota ValeLog no São Lucas na noite do sumiço.", "Fotos", "critical"),
    clue("CLUE_SEQUENCE", "Sequência do crime", "contradiction", "Quadro", "Bruno ordena → Camila atrai → 1717 → loc off → remoto.", "Quadro", "critical"),
]

conversations = [
    conv("conv_rafael", "char_rafael", "Rafael", [
        msg("m_r1", "char_rafael", "Onde você está? Não some de novo.", "2024-08-13T21:40:00"),
        msg("m_r2", "self", "Estou trabalhando. Para de rastrear meu celular.", "2024-08-13T21:42:00"),
        msg("m_r3", "char_rafael", "Eu estou no Lume. Vem. A gente conversa.", "2024-08-13T22:05:00", revealsClueIds=["CLUE_RAFAEL_WHERE"]),
        msg("m_r4", "self", "Eu descobri quem está por trás disso.", "2024-08-13T23:18:00", revealsClueIds=["CLUE_LAST_MSG"]),
        msg("m_r5", "char_rafael", "Marina?? Responde.", "2024-08-13T23:46:00"),
    ], unread=True, reveals=["CLUE_LAST_MSG"]),
    conv("conv_camila", "char_camila", "Camila Duarte", [
        msg("m_c1", "char_camila", "Consegue passar no São Lucas? 23:30. É sobre a pauta. Só nós.", "2024-08-13T22:55:00", revealsClueIds=["CLUE_CAMILA_LURE"]),
        msg("m_c2", "self", "Estranho marcar aí. Mas ok. Saindo do Lume.", "2024-08-13T22:57:00"),
        msg("m_c3", "self", "Camila? Estou no pilar B. Cadê você?", "2024-08-13T23:32:00"),
        msg("m_c4", "char_camila", "Desculpa. Não posso falar agora.", "2024-08-13T23:40:00"),
        msg("m_c5", "char_camila", "", "2024-08-13T22:48:00", kind="deleted", isDeleted=True, deletedPreview="não vá ao estacionamento sozinha", revealsClueIds=["CLUE_MSG_DELETED"]),
    ], unread=True, reveals=["CLUE_CAMILA_LURE"]),
    conv("conv_daniel", "char_daniel", "Daniel Rocha", [
        msg("m_d1", "char_daniel", "A pauta Aurora não sobe. Entendeu?", "2024-08-13T16:40:00", revealsClueIds=["CLUE_EMAIL_DANIEL"]),
        msg("m_d2", "self", "Eu tenho documento. Não é opinião.", "2024-08-13T16:42:00"),
        msg("m_d3", "char_daniel", "Então esquece o documento. Bruno não brinca.", "2024-08-13T16:43:00", revealsClueIds=["CLUE_BRUNO_PRESSURE"]),
    ]),
    conv("conv_rita", "char_rita", "R.", [
        msg("m_ri1", "char_rita", "Apague o rastro. RO. 0403 é a chave.", "2024-08-12T11:02:00", revealsClueIds=["CLUE_R_THREAD", "CLUE_NOTE_R"]),
        msg("m_ri2", "self", "Recebi as planilhas. Obrigada.", "2024-08-12T11:10:00"),
        msg("m_ri3", "char_rita", "Se alguma coisa acontecer, a pasta está no Files.", "2024-08-13T09:14:00", revealsClueIds=["CLUE_NOTE_IF"]),
    ], unread=True, reveals=["CLUE_R_THREAD"]),
    conv("conv_bruno", "char_bruno", "Bruno Vale", [
        msg("m_b1", "char_bruno", "Sua matéria é ficção. Estou em reunião até meia-noite.", "2024-08-13T20:10:00", revealsClueIds=["CLUE_BRUNO_PRESSURE"]),
        msg("m_b2", "self", "Reunião com quem? A frota fantasma também foi?", "2024-08-13T20:12:00"),
        msg("m_b3", "char_bruno", "Cuidado com o que publica, Marina.", "2024-08-13T20:13:00"),
    ]),
    conv("conv_sofia", "char_sofia", "Mãe", [
        msg("m_s1", "char_sofia", "Liga pra mim. Está tarde.", "2024-08-13T22:06:00", revealsClueIds=["CLUE_SOFIA_CALL"]),
        msg("m_s2", "self", "Já já. Trabalho.", "2024-08-13T22:08:00"),
    ]),
    conv("conv_leo", "char_leo", "Leo Segurança", [
        msg("m_l1", "char_leo", "A câmera do B caiu. Disseram manutenção.", "2024-08-13T23:50:00", revealsClueIds=["CLUE_LEO_CAMERA"]),
        msg("m_l2", "self", "Quem mandou?", "2024-08-13T23:51:00"),
        msg("m_l3", "char_leo", "Não posso falar daqui.", "2024-08-13T23:52:00"),
    ]),
    conv("conv_unknown", "char_unknown", "Não atender", [
        msg("m_u1", "char_unknown", "Você não deveria estar olhando isso.", "2024-08-13T23:41:00", revealsClueIds=["CLUE_CALL_UNKNOWN", "CLUE_AUDIO_THREAT"]),
    ], unread=True, reveals=["CLUE_CALL_UNKNOWN"]),
    conv("conv_grupo", "char_daniel", "Redação CN", [
        msg("m_g1", "char_daniel", "Ninguém publica Aurora sem meu ok.", "2024-08-13T18:00:00"),
        msg("m_g2", "char_camila", "Marina, fala comigo antes de sair.", "2024-08-13T18:02:00"),
        msg("m_g3", "self", "Eu vou fechar a pauta hoje.", "2024-08-13T18:05:00"),
    ]),
    conv("conv_av", "char_bruno", "AV Services", [
        msg("m_a1", "char_bruno", "Pagamento confirmado. D. Rocha.", "2024-08-10T10:00:00", revealsClueIds=["CLUE_DANIEL_MONEY"]),
    ]),
    conv("conv_intern", "char_camila", "Estagiária Lia", [
        msg("m_i1", "self", "Manda o clipping do ValeLog.", "2024-08-13T11:00:00"),
        msg("m_i2", "char_camila", "Lia está de folga. Eu mando.", "2024-08-13T11:04:00"),
    ]),
    conv("conv_bank", "char_marina", "NexoBank", [
        msg("m_k1", "char_unknown", "Fatura disponível. Nenhum Pix 80k na sua conta.", "2024-08-13T09:00:00"),
    ]),
    conv("conv_entregador", "char_unknown", "Entrega Lume", [
        msg("m_e1", "char_unknown", "Pedido 22:18 — mesa 4, duas pessoas.", "2024-08-13T22:20:00", revealsClueIds=["CLUE_LOC_RESTAURANT"]),
    ]),
    conv("conv_fonte", "char_rita", "Fonte antiga", [
        msg("m_f1", "char_rita", "Arquivado: não use meu nome.", "2024-08-01T08:00:00"),
    ], unread=False),
    conv("conv_spam", "char_unknown", "OSIS Promo", [
        msg("m_p1", "char_unknown", "Atualize o sistema.", "2024-08-12T12:00:00"),
    ]),
]

photos = [
    {"id": "ph1", "title": "Lume — mesa", "caption": "22:14", "visualDescription": "Bar escuro, dois copos, reflexo no vidro", "takenAt": "2024-08-13T22:14:00", "locationName": "Bar Lume", "colorSeed": "21", "revealsClueIds": ["CLUE_PHOTO_REFLECTION"], "hotspots": [{"id": "h1", "x": 0.7, "y": 0.4, "w": 0.15, "h": 0.15, "label": "Reflexo", "revealsClueIds": ["CLUE_PHOTO_REFLECTION"]}]},
    {"id": "ph2", "title": "Contrato print", "caption": "Aurora p.1", "visualDescription": "Documento com logo ValeLog", "takenAt": "2024-08-13T19:40:00", "isScreenshot": True, "colorSeed": "44", "revealsClueIds": ["CLUE_CONTRACT_AURORA"], "hotspots": []},
    {"id": "ph3", "title": "Pilar B", "caption": "Cheguei", "visualDescription": "Estacionamento vazio, luz amarela", "takenAt": "2024-08-13T23:31:00", "metadataTakenAt": "2024-08-13T21:00:00", "locationName": "Estacionamento São Lucas", "colorSeed": "71", "revealsClueIds": ["CLUE_PARKING", "CLUE_META_MISMATCH"], "hotspots": []},
    {"id": "ph4", "title": "SUV na rampa", "caption": "Quem é?", "visualDescription": "SUV preto, placa parcial, adesivo ValeLog", "takenAt": "2024-08-13T23:33:00", "locationName": "Estacionamento São Lucas", "colorSeed": "18", "revealsClueIds": ["CLUE_PHOTO_PLATE"], "hotspots": [{"id": "h2", "x": 0.6, "y": 0.55, "w": 0.14, "h": 0.12, "label": "Placa", "revealsClueIds": ["CLUE_PHOTO_PLATE", "CLUE_BRUNO_CAR"]}]},
    {"id": "ph5", "title": "Selfie redação", "caption": "Camila ao fundo", "visualDescription": "Marina na redação, Camila tensa", "takenAt": "2024-08-13T17:10:00", "colorSeed": "33", "revealsClueIds": [], "hotspots": []},
    {"id": "ph6", "title": "Print Pix", "caption": "80 mil", "visualDescription": "Comprovante AV Services → D. Rocha", "takenAt": "2024-08-11T10:00:00", "isScreenshot": True, "colorSeed": "09", "revealsClueIds": ["CLUE_DANIEL_MONEY"], "hotspots": []},
    {"id": "ph7", "title": "Nota R.", "caption": "Foto da mesa", "visualDescription": "Caderno: R. = RO", "takenAt": "2024-08-12T21:00:00", "colorSeed": "62", "revealsClueIds": ["CLUE_NOTE_R"], "hotspots": []},
    {"id": "ph8", "title": "Mãe no aniversário", "caption": "Setembro", "visualDescription": "Sofia e Marina, bolo, 09/12 na faixa", "takenAt": "2023-09-12T19:00:00", "colorSeed": "51", "revealsClueIds": [], "hotspots": []},
    {"id": "ph9", "title": "Câmera apagada", "caption": "São Lucas", "visualDescription": "Dome camera com LED off", "takenAt": "2024-08-13T23:35:00", "colorSeed": "14", "revealsClueIds": ["CLUE_LEO_CAMERA"], "hotspots": []},
    {"id": "ph10", "title": "Lixeira — print", "caption": "apagado", "visualDescription": "Print de chat apagado", "takenAt": "2024-08-13T23:00:00", "deleted": True, "colorSeed": "28", "revealsClueIds": ["CLUE_MSG_DELETED"], "hotspots": []},
    {"id": "ph11", "title": "Mapa pilar B", "caption": "Pin", "visualDescription": "Maps com pin no São Lucas", "takenAt": "2024-08-13T22:50:00", "isScreenshot": True, "colorSeed": "37", "revealsClueIds": ["CLUE_BROWSER_LOC"], "hotspots": []},
    {"id": "ph12", "title": "Frota ValeLog", "caption": "Arquivo", "visualDescription": "Caminhões com logo", "takenAt": "2024-08-08T15:00:00", "colorSeed": "80", "revealsClueIds": ["CLUE_AURORA_SHEETS"], "hotspots": []},
]

calls = [
    {"id": "call1", "contactId": "char_unknown", "displayName": "+55 11 90000-1717", "number": "+55 11 90000-1717", "type": "incoming", "timestamp": "2024-08-13T23:41:00", "durationSeconds": 41, "unknown": True, "revealsClueIds": ["CLUE_CALL_UNKNOWN", "CLUE_UNKNOWN_1717"]},
    {"id": "call2", "contactId": "char_daniel", "displayName": "Daniel Rocha", "type": "incoming", "timestamp": "2024-08-13T21:02:00", "durationSeconds": 186, "revealsClueIds": ["CLUE_CALL_DANIEL"]},
    {"id": "call3", "contactId": "char_sofia", "displayName": "Mãe", "type": "incoming", "timestamp": "2024-08-13T22:05:00", "durationSeconds": 94, "revealsClueIds": ["CLUE_SOFIA_CALL"]},
    {"id": "call4", "contactId": "char_camila", "displayName": "Camila Duarte", "type": "missed", "timestamp": "2024-08-13T23:44:00", "durationSeconds": 0, "revealsClueIds": ["CLUE_VOICEMAIL"]},
    {"id": "call5", "contactId": "char_rafael", "displayName": "Rafael", "type": "outgoing", "timestamp": "2024-08-13T20:30:00", "durationSeconds": 32, "revealsClueIds": []},
    {"id": "call6", "contactId": "char_bruno", "displayName": "Bruno Vale", "type": "missed", "timestamp": "2024-08-13T19:10:00", "durationSeconds": 0, "revealsClueIds": ["CLUE_BRUNO_PRESSURE"]},
    {"id": "call7", "contactId": "char_leo", "displayName": "Leo Segurança", "type": "outgoing", "timestamp": "2024-08-13T23:49:00", "durationSeconds": 22, "revealsClueIds": ["CLUE_LEO_CAMERA"]},
    {"id": "call8", "contactId": "char_rita", "displayName": "R.", "type": "incoming", "timestamp": "2024-08-12T11:00:00", "durationSeconds": 120, "revealsClueIds": ["CLUE_R_THREAD"]},
]

emails = [
    {"id": "em1", "from": "daniel.rocha@cronicanorte.news", "to": ["marina.alves@cronicanorte.news"], "subject": "Pauta Aurora", "body": "Marina, segura a matéria. A diretoria não autoriza. Apague o rascunho.", "timestamp": "2024-08-13T16:38:00", "revealsClueIds": ["CLUE_EMAIL_DANIEL"]},
    {"id": "em2", "from": "rita.okamoto@valelog.com.br", "to": ["marina.alves@cronicanorte.news"], "subject": "não use meu nome", "body": "Sou Rita Okamoto. R. nas mensagens. 0403 abre a pasta. Apague este e-mail.", "timestamp": "2024-08-12T10:55:00", "revealsClueIds": ["CLUE_EMAIL_RITA"]},
    {"id": "em3", "from": "leo.pires@saolucas.park", "to": ["marina.alves@cronicanorte.news"], "subject": "Câmera B", "body": "A câmera do pilar B 'caiu' por ordem de manutenção emergencial. Não foi pane.", "timestamp": "2024-08-14T07:12:00", "revealsClueIds": ["CLUE_LEO_CAMERA"]},
    {"id": "em4", "from": "bruno.vale@valelog.com.br", "to": ["marina.alves@cronicanorte.news"], "subject": "Notificação extrajudicial", "body": "Qualquer publicação sobre Aurora será respondida na justiça.", "timestamp": "2024-08-13T19:00:00", "revealsClueIds": ["CLUE_BRUNO_PRESSURE"]},
    {"id": "em5", "from": "marina.alves@cronicanorte.news", "to": ["daniel.rocha@cronicanorte.news"], "subject": "(rascunho) Eu publico mesmo assim", "body": "Daniel, eu sei do Pix. AV Services. 80 mil.", "timestamp": "2024-08-13T21:20:00", "isDraft": True, "revealsClueIds": ["CLUE_DANIEL_MONEY"]},
    {"id": "em6", "from": "noreply@avservices.example", "to": ["marina.alves@cronicanorte.news"], "subject": "Fatura", "body": "Serviços de inteligência. Cliente: ValeLogística.", "timestamp": "2024-08-09T09:00:00", "isSpam": True, "revealsClueIds": ["CLUE_REMOTE_ACCESS"]},
]

notes = [
    {"id": "n1", "title": "Se alguma coisa acontecer comigo", "body": "Se alguma coisa acontecer comigo, abre Files → Aurora. Senha = aniversário de R. (0403).\nPIN do celular: mês do pai + o que eu nunca esqueço.", "updatedAt": "2024-08-13T21:50:00", "revealsClueIds": ["CLUE_NOTE_IF"]},
    {"id": "n2", "title": "R. = RO", "body": "Não é Rafael. RO. Rita. Analista. Ela vazou as abas da frota fantasma.", "updatedAt": "2024-08-12T22:10:00", "revealsClueIds": ["CLUE_NOTE_R"]},
    {"id": "n3", "title": "Álibis", "body": "Rafael: Lume.\nDaniel: redação.\nBruno: 'reunião'.\nCamila: casa? Conferir GPS dela depois.", "updatedAt": "2024-08-13T20:40:00", "revealsClueIds": []},
    {"id": "n4", "title": "1717", "body": "Número que aparece em recados da ValeLog. Pré-pago. Não atender.", "updatedAt": "2024-08-13T18:22:00", "revealsClueIds": ["CLUE_UNKNOWN_1717"]},
    {"id": "n5", "title": "Lista Aurora", "body": "Contrato, planilha, Pix, câmera, isca.", "updatedAt": "2024-08-13T19:05:00", "locked": True, "revealsClueIds": ["CLUE_FILE_AURORA"]},
    {"id": "n6", "title": "Pilar B", "body": "Camila marcou 23:30. Chegar e filmar o carro se aparecer.", "updatedAt": "2024-08-13T22:58:00", "revealsClueIds": ["CLUE_CAL_EVENT"]},
]

files = [
    {"id": "f1", "name": "aurora_planilha.xlsx", "path": "/Files/Aurora/", "type": "xlsx", "modifiedAt": "2024-08-12T11:20:00", "passwordProtected": True, "password": "0403", "content": "Aba Frota Fantasma\nPlacas NEX-4A71 … NEX-4A90 sem motorista.\nAba Propina: AV Services 80.000 — D. Rocha.\nAssinatura digital: B. Vale.", "revealsClueIds": ["CLUE_FILE_AURORA", "CLUE_AURORA_SHEETS"]},
    {"id": "f2", "name": "contrato_aurora.pdf", "path": "/Files/Aurora/", "type": "pdf", "modifiedAt": "2024-08-12T11:22:00", "content": "Contrato Aurora — ValeLogística × município.\nCláusula 17: veículos em operação contínua.\nNa prática: frota papel.", "revealsClueIds": ["CLUE_CONTRACT_AURORA"]},
    {"id": "f3", "name": "arquivo_00017.dat", "path": "/System/hidden/", "type": "dat", "modifiedAt": "2024-08-13T23:47:00", "hidden": True, "passwordProtected": True, "password": "2347", "content": "SESSÃO REMOTA AV-PROXY\nlast_charge=23:47\noperator=unknown", "revealsClueIds": ["CLUE_FILE_DAT", "CLUE_REMOTE_ACCESS"]},
    {"id": "f4", "name": "backup_pulse_partial.bak", "path": "/Lixeira/", "type": "bak", "modifiedAt": "2024-08-13T23:01:00", "content": "Camila marcou. Não confia. Não vá sozinha.", "revealsClueIds": ["CLUE_RECOVERED_FRAGMENT"]},
    {"id": "f5", "name": "comprovante_av.pdf", "path": "/Downloads/", "type": "pdf", "modifiedAt": "2024-08-11T10:02:00", "content": "Pix R$ 80.000 · AV Services → Daniel Rocha", "revealsClueIds": ["CLUE_DANIEL_MONEY"]},
    {"id": "f6", "name": "notas_ro.txt", "path": "/Files/", "type": "txt", "modifiedAt": "2024-08-12T22:11:00", "content": "RO = Rita Okamoto. Aniversário 04/03.", "revealsClueIds": ["CLUE_NOTE_R"]},
]

data = {
    "id": "case_001",
    "title": "A Última Mensagem",
    "subtitle": "Marina Alves · 27 · jornalista",
    "synopsis": "Marina Alves desaparece após enviar: «Eu descobri quem está por trás disso.» O VANTA é encontrado no Estacionamento São Lucas em 14/08.",
    "victimId": "char_marina",
    "deviceFoundAt": "2024-08-14T09:10:00",
    "lockPin": "0912",
    "lockHint": "Mês + algo que ela nunca esqueceu",
    "osState": {
        "battery": 87,
        "wifi": True,
        "bluetooth": True,
        "carrier": "Nexa",
        "deviceName": "VANTA S",
        "osName": "OSIS 14.1",
        "wallpaper": "dusk_harbor",
        "lastChargeAt": "13/08 23:47",
        "lastLocationUpdate": "13/08 23:28 — São Lucas (depois: off)",
        "targetPlaySeconds": 1800,
    },
    "settingsHints": {
        "batteryDrop": "Queda anormal após 23:40. Possível sessão remota.",
        "storageMystery": "arquivo_00017.dat oculto",
    },
    "characters": characters,
    "contacts": [
        {"id": "char_rafael", "name": "Rafael Mendes", "phone": "+55 11 96666-8181", "favorite": True, "notes": "Ex. Não ligar depois das 22h."},
        {"id": "char_camila", "name": "Camila Duarte", "phone": "+55 11 97771-3300", "favorite": True},
        {"id": "char_daniel", "name": "Daniel Rocha", "phone": "+55 11 97777-2211"},
        {"id": "char_rita", "name": "R.", "phone": "+55 11 95555-0403", "notes": "Fonte. Não salvar sob o nome real."},
        {"id": "char_bruno", "name": "Bruno Vale", "phone": "+55 11 90000-1717"},
        {"id": "char_sofia", "name": "Sofia Alves", "phone": "+55 11 98812-0001", "favorite": True, "notes": "Mãe"},
        {"id": "char_leo", "name": "Leonardo Pires", "phone": "+55 11 93400-2210"},
        {"id": "char_unknown", "name": "Não atender", "phone": "+55 11 90000-1717", "notes": "Pré-pago. 1717."},
    ],
    "clues": clues,
    "conversations": conversations,
    "photos": photos,
    "calls": calls,
    "emails": emails,
    "notes": notes,
    "files": files,
    "locations": [
        {"id": "loc1", "name": "Redação Crônica Norte", "kind": "history", "lat": -23.56, "lng": -46.65, "visitedAt": "2024-08-13T19:00:00"},
        {"id": "loc2", "name": "Bar Lume", "kind": "history", "lat": -23.57, "lng": -46.64, "visitedAt": "2024-08-13T22:10:00", "revealsClueIds": ["CLUE_LOC_RESTAURANT"]},
        {"id": "loc3", "name": "Restaurante Lume — pesquisa", "kind": "searched", "lat": -23.57, "lng": -46.64, "note": "mesa 4", "revealsClueIds": ["CLUE_LOC_RESTAURANT"]},
        {"id": "loc4", "name": "Estacionamento São Lucas — pilar B", "kind": "history", "lat": -23.59, "lng": -46.64, "visitedAt": "2024-08-13T23:31:00", "revealsClueIds": ["CLUE_PARKING"]},
        {"id": "loc5", "name": "Casa (Sofia)", "kind": "favorite", "lat": -23.54, "lng": -46.68},
        {"id": "loc6", "name": "ValeLogística HQ", "kind": "searched", "lat": -23.52, "lng": -46.63, "note": "pauta Aurora"},
    ],
    "browserHistory": [
        {"id": "br1", "title": "Estacionamento São Lucas pilar B", "url": "https://maps.example/sao-lucas", "visitedAt": "2024-08-13T22:49:00", "snippet": "Pilar B, subsolo 2.", "revealsClueIds": ["CLUE_BROWSER_LOC"]},
        {"id": "br2", "title": "Contrato Aurora PDF", "url": "https://drive.example/aurora", "visitedAt": "2024-08-13T19:38:00", "revealsClueIds": ["CLUE_CONTRACT_AURORA"]},
        {"id": "br3", "title": "AV Services inteligência", "url": "https://avservices.example", "visitedAt": "2024-08-13T20:01:00", "revealsClueIds": ["CLUE_REMOTE_ACCESS"]},
        {"id": "br4", "title": "Como recuperar mensagens apagadas", "url": "https://support.example/whatsapp", "visitedAt": "2024-08-13T23:02:00", "revealsClueIds": ["CLUE_MSG_DELETED"]},
        {"id": "br5", "title": "Rita Okamoto LinkedIn", "url": "https://linkedin.example/rita-okamoto", "visitedAt": "2024-08-12T21:40:00", "revealsClueIds": ["CLUE_NOTE_R"]},
        {"id": "br6", "title": "ValeLogística frota", "url": "https://valelog.example/frota", "visitedAt": "2024-08-08T16:00:00"},
        {"id": "br7", "title": "Bar Lume cardápio", "url": "https://lume.example", "visitedAt": "2024-08-13T21:55:00"},
        {"id": "br8", "title": "NexoBank comprovantes", "url": "https://nexobank.example", "visitedAt": "2024-08-11T10:05:00", "revealsClueIds": ["CLUE_DANIEL_MONEY"]},
    ],
    "timeline": [
        {"id": "tl1", "timestamp": "2024-08-13T16:40:00", "description": "Daniel manda segurar a pauta Aurora", "source": "WhatsApp / Mail", "reliability": 0.9, "initiallyVisible": True, "unlockWithClueIds": []},
        {"id": "tl2", "timestamp": "2024-08-13T20:10:00", "description": "Bruno alega reunião até meia-noite", "source": "WhatsApp", "reliability": 0.6, "initiallyVisible": True, "unlockWithClueIds": []},
        {"id": "tl3", "timestamp": "2024-08-13T22:05:00", "description": "Sofia liga; Rafael chama ao Lume", "source": "Telefone / WhatsApp", "reliability": 0.8, "initiallyVisible": True, "unlockWithClueIds": []},
        {"id": "tl4", "timestamp": "2024-08-13T22:14:00", "description": "Foto no Lume — reflexo de Camila", "source": "Fotos", "reliability": 0.85, "initiallyVisible": False, "unlockWithClueIds": ["CLUE_PHOTO_REFLECTION"]},
        {"id": "tl5", "timestamp": "2024-08-13T22:55:00", "description": "Camila marca o São Lucas às 23:30", "source": "WhatsApp", "reliability": 0.98, "initiallyVisible": False, "unlockWithClueIds": ["CLUE_CAMILA_LURE"]},
        {"id": "tl6", "timestamp": "2024-08-13T23:18:00", "description": "Última mensagem: 'Eu descobri quem está por trás disso.'", "source": "WhatsApp", "reliability": 0.99, "initiallyVisible": False, "unlockWithClueIds": ["CLUE_LAST_MSG"]},
        {"id": "tl7", "timestamp": "2024-08-13T23:28:00", "description": "GPS desligado. Último ponto: São Lucas", "source": "Ajustes", "reliability": 0.95, "initiallyVisible": False, "unlockWithClueIds": ["CLUE_LOC_OFF"]},
        {"id": "tl8", "timestamp": "2024-08-13T23:31:00", "description": "Marina no pilar B", "source": "Fotos / Mapas", "reliability": 0.97, "initiallyVisible": False, "unlockWithClueIds": ["CLUE_PARKING"]},
        {"id": "tl9", "timestamp": "2024-08-13T23:41:00", "description": "Ligação do 1717", "source": "Telefone", "reliability": 0.9, "initiallyVisible": False, "unlockWithClueIds": ["CLUE_CALL_UNKNOWN"]},
        {"id": "tl10", "timestamp": "2024-08-13T23:47:00", "description": "Última carga / sessão remota", "source": "Sistema", "reliability": 0.8, "initiallyVisible": False, "unlockWithClueIds": ["CLUE_FILE_DAT"]},
        {"id": "tl11", "timestamp": "2024-08-14T09:10:00", "description": "VANTA encontrado no São Lucas", "source": "Boletim", "reliability": 1.0, "initiallyVisible": True, "unlockWithClueIds": []},
        {"id": "tl12", "timestamp": "2024-08-13T23:33:00", "description": "SUV ValeLog fotografado na rampa", "source": "Fotos", "reliability": 0.92, "initiallyVisible": False, "unlockWithClueIds": ["CLUE_PHOTO_PLATE"]},
    ],
    "endings": [
        {"id": "end_a", "code": "A", "title": "A ordem veio de cima", "summary": "Bruno Vale como mandante, com evidência sólida.", "epilogue": "Bruno é indiciado. A frota fantasma vira CPI. Marina continua desaparecida — mas a mentira oficial cai.", "requirements": {"accuse": "char_bruno", "minScore": 55, "priority": 50}},
        {"id": "end_b", "code": "B", "title": "Acusação errada", "summary": "A pessoa errada leva a culpa.", "epilogue": "A denúncia se desfaz. O telefone de Marina nunca mais acende.", "requirements": {"minScore": 20, "priority": 10}},
        {"id": "end_c", "code": "C", "title": "Metade da verdade", "summary": "Só Camila.", "epilogue": "Camila confessa o encontro. Bruno escapa. Aurora segue intacto.", "requirements": {"accuse": "char_camila", "minScore": 35, "priority": 30}},
        {"id": "end_d", "code": "D", "title": "A conspiração inteira", "summary": "Bruno, a isca, o remoto e as contradições.", "epilogue": "Quadro completo: Bruno ordena, Camila atrai, Daniel cobre, 1717, São Lucas, acesso remoto. A última mensagem vira prova.", "requirements": {"accuse": "char_bruno", "minScore": 70, "requiredClues": ["CLUE_SEQUENCE", "CLUE_CAMILA_LURE", "CLUE_REMOTE_ACCESS"], "remoteAccess": True, "priority": 100}},
        {"id": "end_e", "code": "E", "title": "Evidências insuficientes", "summary": "Pouca prova.", "epilogue": "O caso esfria. Resta um VANTA com 4% de bateria e uma frase no ar.", "requirements": {"maxScore": 34, "priority": 5}},
    ],
    "unlockRules": [
        {"id": "rule_r_identity", "requiredClueIds": ["CLUE_NOTE_R", "CLUE_EMAIL_RITA"], "minRequired": 2, "unlockClueIds": ["CLUE_R_IDENTITY"], "notificationText": "R. tem nome: Rita Okamoto."},
        {"id": "rule_lure", "requiredClueIds": ["CLUE_VOICEMAIL", "CLUE_CAMILA_LURE"], "minRequired": 2, "unlockClueIds": ["CLUE_SEQUENCE"], "unlockTimelineIds": ["tl5"]},
        {"id": "rule_dat", "requiredClueIds": ["CLUE_FILE_DAT"], "unlockContentIds": ["f3"], "notificationText": "Arquivo de sistema recuperado."},
    ],
    "liveEvents": [
        {"id": "le1", "trigger": "time", "delaySeconds": 0, "type": "message", "condition": {"deviceUnlocked": True, "minElapsedSeconds": 90, "missingAnyClues": ["CLUE_LAST_MSG"], "endingChosen": False}, "payload": {"from": "Sofia Alves", "body": "Olha o WhatsApp dela. A última mensagem ainda está lá.", "revealsClueIds": []}},
        {"id": "le2", "trigger": "time", "delaySeconds": 0, "type": "message", "condition": {"deviceUnlocked": True, "minElapsedSeconds": 240, "missingAnyClues": ["CLUE_PARKING"], "endingChosen": False}, "payload": {"from": "Leonardo Pires", "body": "Se o aparelho estava no São Lucas, o GPS mente? Abre Mapas e Ajustes."}},
        {"id": "le3", "trigger": "open_app", "delaySeconds": 2, "type": "island", "condition": {"appId": "settings", "deviceUnlocked": True}, "payload": {"state": "unknownActivity", "label": "sessão remota?"}},
    ],
    "contradictions": [
        {"id": "CONTRA_RAFAEL_LUME", "statement": "Rafael diz que estava só no Lume, sem rastrear Marina", "characterId": "char_rafael", "evidenceClueIds": ["CLUE_RAFAEL_WHERE", "CLUE_LAST_MSG"], "resolution": "Ele cobrava localização o tempo todo. É pista falsa forte, não o mandante.", "revealsClueIds": []},
        {"id": "CONTRA_BRUNO_MEETING", "statement": "Bruno estava em reunião até meia-noite", "characterId": "char_bruno", "evidenceClueIds": ["CLUE_BRUNO_PRESSURE", "CLUE_PHOTO_PLATE"], "resolution": "A frota ValeLog está no São Lucas. O álibi não segura.", "revealsClueIds": ["CLUE_BRUNO_CAR"]},
        {"id": "CONTRA_CAMILA_HOME", "statement": "Camila só avisou a colega e foi para casa", "characterId": "char_camila", "evidenceClueIds": ["CLUE_CAMILA_LURE", "CLUE_VOICEMAIL"], "resolution": "Ela marcou o pilar B e depois pediu desculpas no correio.", "revealsClueIds": ["CLUE_SEQUENCE"]},
        {"id": "CONTRA_DANIEL_ETHICS", "statement": "Daniel só seguia a linha editorial", "characterId": "char_daniel", "evidenceClueIds": ["CLUE_EMAIL_DANIEL", "CLUE_DANIEL_MONEY"], "resolution": "O Pix de 80 mil da AV Services compra o silêncio.", "revealsClueIds": []},
    ],
    "puzzles": [
        {"id": "pz_aurora", "answer": "0403", "alternateAnswers": ["04/03", "4/3", "0403 "], "unlockOnSolve": ["f1", "CLUE_FILE_AURORA"], "relatedClueIds": ["CLUE_FILE_AURORA", "CLUE_NOTE_R"]},
        {"id": "pz_dat", "answer": "2347", "alternateAnswers": ["23:47"], "unlockOnSolve": ["f3", "CLUE_FILE_DAT"], "relatedClueIds": ["CLUE_FILE_DAT"]},
    ],
    "calendarEvents": [
        {"id": "cal1", "title": "Pauta (São Lucas)", "start": "2024-08-13T23:30:00", "end": "2024-08-13T23:50:00", "location": "Estacionamento São Lucas", "notes": "Camila marcou", "revealsClueIds": ["CLUE_CAL_EVENT"]},
        {"id": "cal2", "title": "Fechamento Aurora", "start": "2024-08-13T18:00:00", "location": "Redação", "revealsClueIds": ["CLUE_EMAIL_DANIEL"]},
        {"id": "cal3", "title": "Aniversário pai (lembrete)", "start": "2023-09-12T00:00:00", "notes": "09/12 — PIN", "revealsClueIds": []},
    ],
    "initialNotifications": [
        {"id": "nlock1", "appId": "pulse", "title": "WhatsApp", "body": "Rafael: Marina?? Responde.", "timestamp": "2024-08-13T23:46:00", "revealsClueIds": ["CLUE_LAST_MSG"]},
        {"id": "nlock2", "appId": "calls", "title": "Telefone", "body": "1 chamada perdida de Camila", "timestamp": "2024-08-13T23:44:00"},
        {"id": "nlock3", "appId": "atlas", "title": "Mapas", "body": "Última localização: São Lucas", "timestamp": "2024-08-13T23:28:00", "revealsClueIds": ["CLUE_PARKING"]},
    ],
}

OUT.parent.mkdir(parents=True, exist_ok=True)
OUT.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
print(f"Wrote {OUT} ({OUT.stat().st_size} bytes)")
print("clues", len(data["clues"]), "conversations", len(data["conversations"]), "endings", len(data["endings"]))
