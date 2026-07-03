#!/usr/bin/env python3
"""Generate preview/hubfu-integrations-data.js from HubFU catalog."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "preview" / "hubfu-integrations-data.js"

# slug: simple-icons name; None = use initials fallback
LOGO = {
    "asaas": None,
    "erpnext": "erpnext",
    "formularios": None,
    "gmail": "gmail",
    "googlecalendar": "googlecalendar",
    "kommo": None,
    "krayin": None,
    "melhorenvio": None,
    "mercadolibre": None,
    "notion": "notion",
    "nuvemshop": None,
    "shopify": "shopify",
    "frenet": None,
    "googleads": "googleads",
    "googleforms": "googleforms",
    "googlesheets": "googlesheets",
    "googleshopping": "google",
    "hubspot": "hubspot",
    "hubspotforms": "hubspot",
    "instagram": "instagram",
    "mailchimp": "mailchimp",
    "meta": "meta",
    "paypal": "paypal",
    "rdstation": None,
    "salesforce": "salesforce",
    "slack": "slack",
    "stripe": "stripe",
    "typeform": "typeform",
    "whatsapp": "whatsapp",
    "zoom": "zoom",
    "amazon": "amazon",
    "bling": None,
    "eduzz": None,
    "hotmart": None,
    "kiwify": None,
    "make": "make",
    "mercadopago": "mercadopago",
    "pagseguro": "pagseguro",
    "shopee": "shopee",
    "tiktok": "tiktok",
    "twilio": "twilio",
    "woocommerce": "woocommerce",
    "zapier": "zapier",
    "asana": "asana",
    "docusign": "docusign",
    "dropbox": "dropbox",
    "facebookmessenger": "facebook",
    "googleanalytics": "googleanalytics",
    "googledrive": "googledrive",
    "microsoftteams": "microsoftteams",
    "mixpanel": "mixpanel",
    "n8n": "n8n",  # simple-icons >= 13
    "telegram": "telegram",
    "trello": "trello",
}

ITEMS = [
    ("asaas", "Asaas", "Pagamentos", 1, 1, "Cobranças, boletos e PIX — webhook financeiro HubFU.", "Webhook", "connected", "Ativo"),
    ("erpnext", "ERPNext", "ERP & CRM", 4, 3, "ERP nativo — produtos, pedidos, fiscal e estoque.", "API Key", "connected", "Ativo"),
    ("formularios", "Formulários HubFU", "Formulários", 1, 1, "Formulário público embedável — captura leads direto no CRM Krayin.", "API Key", "connected", "Gerenciar"),
    ("gmail", "Gmail", "Produtividade", 14, 2, "E-mail no Copilot — busca e contexto para equipe.", "OAuth2", "connected", "Ativo"),
    ("googlecalendar", "Google Calendar", "Produtividade", 10, 2, "Agenda Google no Assistente — eventos e compromissos.", "OAuth2", "connected", "Ativo"),
    ("kommo", "Kommo (importação)", "ERP & CRM", 4, 3, "Migrar dados do Kommo — OAuth + wizard de importação.", "OAuth2", "connected", "Gerenciar"),
    ("krayin", "Krayin CRM", "ERP & CRM", 4, 3, "CRM Krayin — pipeline, leads e atividades.", "API Key", "connected", "Ativo"),
    ("melhorenvio", "Melhor Envio", "Frete & Logística", 1, 1, "Cotação e etiquetas Melhor Envio por tenant.", "OAuth2", "connected", "Gerenciar"),
    ("mercadolibre", "Mercado Livre", "E-commerce & Marketplaces", 4, 2, "Pedidos, estoque e anúncios ML — OAuth nativo BR.", "OAuth2", "connected", "Gerenciar"),
    ("notion", "Notion", "Produtividade", 12, 2, "Base de conhecimento da empresa no Copilot.", "OAuth2", "connected", "Ativo"),
    ("nuvemshop", "Nuvemshop", "E-commerce & Marketplaces", 4, 2, "E-commerce BR — OAuth Tiendanube/Nuvemshop.", "OAuth2", "connected", "Gerenciar"),
    ("shopify", "Shopify", "E-commerce & Marketplaces", 4, 2, "Loja Shopify — pedidos, produtos, cupons e carrinhos abandonados.", "OAuth2", "connected", "Gerenciar"),
    ("frenet", "Frenet", "Frete & Logística", 1, 1, "Agregador Frenet — token API por empresa.", "API Key", "available", "Conectar"),
    ("googleads", "Google Ads", "Marketing & Ads", 12, 2, "Métricas de campanhas Google Ads.", "OAuth2", "available", "Conectar"),
    ("googleforms", "Google Forms", "Formulários", 6, 2, "Respostas Google Forms no Copilot — OAuth por usuário.", "OAuth2", "available", "Conectar"),
    ("googlesheets", "Google Sheets", "Produtividade", 8, 2, "Planilhas Google — export e automações.", "OAuth2", "available", "Conectar"),
    ("googleshopping", "Google Shopping", "E-commerce & Marketplaces", 4, 2, "Feed GMC por URL — Merchant Center sem OAuth Google.", "API Key", "available", "Conectar"),
    ("hubspot", "HubSpot CRM", "Automação & iPaaS", 18, 2, "Sync bidirecional HubSpot ↔ HubFU.", "OAuth2", "available", "Conectar"),
    ("hubspotforms", "HubSpot Forms", "Formulários", 18, 2, "Captura HubSpot — usa conexão HubSpot CRM (mesmo OAuth).", "OAuth2", "available", "Conectar"),
    ("instagram", "Instagram", "Mensageiros", 3, 1, "DMs, comentários e publicação via Meta Graph API.", "API Key", "available", "Conectar"),
    ("mailchimp", "Mailchimp", "Marketing & Ads", 10, 2, "Campanhas e listas Mailchimp.", "OAuth2", "available", "Conectar"),
    ("meta", "Meta Ads", "Marketing & Ads", 10, 2, "Facebook/Instagram Ads — leads e ROI.", "OAuth2", "available", "Conectar"),
    ("paypal", "PayPal", "Pagamentos", 8, 2, "Faturas e checkout PayPal via Composio.", "OAuth2", "available", "Conectar"),
    ("rdstation", "RD Station", "Marketing & Ads", 3, 1, "Automação de marketing RD Station — conector nativo.", "Webhook", "available", "Conectar"),
    ("salesforce", "Salesforce", "Automação & iPaaS", 22, 2, "Salesforce CRM — leads e oportunidades via Composio.", "OAuth2", "available", "Conectar"),
    ("slack", "Slack", "Produtividade", 6, 2, "Notificações e comandos Slack para equipe.", "OAuth2", "available", "Conectar"),
    ("stripe", "Stripe", "Pagamentos", 16, 2, "Pagamentos internacionais — clientes e assinaturas via Composio.", "OAuth2", "available", "Conectar"),
    ("typeform", "Typeform", "Formulários", 8, 2, "Respostas de formulários → leads no CRM Krayin.", "OAuth2", "available", "Conectar"),
    ("whatsapp", "WhatsApp Business", "Mensageiros", 3, 1, "Atendimento omnicanal via Evolution API — inbox unificado com CRM.", "API Key", "available", "Conectar"),
    ("zoom", "Zoom", "Telefonia & VoIP", 6, 2, "Reuniões Zoom agendadas a partir do deal.", "OAuth2", "beta", "Conectar"),
    ("amazon", "Amazon BR", "E-commerce & Marketplaces", 4, 2, "Seller Central Brasil — SP-API pedidos e SKUs.", "OAuth2", "beta", "Conectar"),
    ("bling", "Bling", "ERP & CRM", 4, 3, "ERP/fiscal SMB BR — pedidos e contatos via API v3.", "Webhook", "beta", "Conectar"),
    ("eduzz", "Eduzz", "Infoprodutos & Cursos", 1, 1, "Plataforma de infoprodutos — vendas e contratos via webhook nativo.", "Webhook", "beta", "Conectar"),
    ("hotmart", "Hotmart", "Infoprodutos & Cursos", 1, 1, "Plataforma de infoprodutos — compras e assinaturas via webhook.", "Webhook", "beta", "Conectar"),
    ("kiwify", "Kiwify", "Infoprodutos & Cursos", 1, 1, "Plataforma de infoprodutos — pedidos e assinaturas via webhook.", "Webhook", "beta", "Conectar"),
    ("make", "Make (Integromat)", "Automação & iPaaS", 4, 3, "Cenários Make — webhook HTTP para eventos HubFU.", "Webhook", "beta", "Conectar"),
    ("mercadopago", "Mercado Pago", "Pagamentos", 1, 1, "Gateway Mercado Pago Brasil — conector nativo.", "Webhook", "beta", "Conectar"),
    ("pagseguro", "PagSeguro", "Pagamentos", 1, 1, "Gateway PagSeguro/PagBank Brasil — conector nativo.", "Webhook", "beta", "Conectar"),
    ("shopee", "Shopee", "E-commerce & Marketplaces", 4, 2, "Marketplace Shopee — pedidos e catálogo.", "OAuth2", "beta", "Conectar"),
    ("tiktok", "TikTok", "Mensageiros", 5, 2, "Conta Business TikTok — publicação e TikTok Shop.", "OAuth2", "beta", "Conectar"),
    ("twilio", "Twilio", "Telefonia & VoIP", 1, 1, "SMS e click-to-call no drawer CRM.", "API Key", "beta", "Conectar"),
    ("woocommerce", "WooCommerce", "E-commerce & Marketplaces", 4, 2, "Loja WordPress/WooCommerce — pedidos via webhook.", "Webhook", "beta", "Conectar"),
    ("zapier", "Zapier", "Automação & iPaaS", 4, 3, "Zaps Zapier — eventos HubFU via webhook outbound.", "Webhook", "beta", "Conectar"),
    ("asana", "Asana", "Produtividade", 8, 2, "Projetos Asana — espelho de tarefas CRM.", "Sem auth", "soon", "Em breve"),
    ("docusign", "DocuSign", "Documentos & Assinatura", 8, 2, "Assinatura eletrônica de propostas.", "Sem auth", "soon", "Em breve"),
    ("dropbox", "Dropbox", "Documentos & Assinatura", 8, 2, "Armazenamento Dropbox para anexos CRM.", "Sem auth", "soon", "Em breve"),
    ("facebookmessenger", "Facebook Messenger", "Mensageiros", 8, 2, "Página Facebook → conversas no inbox HubFU.", "Sem auth", "soon", "Em breve"),
    ("googleanalytics", "Google Analytics", "Analytics & BI", 8, 2, "Tráfego e conversões GA4 no painel.", "Sem auth", "soon", "Em breve"),
    ("googledrive", "Google Drive", "Documentos & Assinatura", 8, 2, "Arquivos Drive anexados a deals e leads.", "Sem auth", "soon", "Em breve"),
    ("microsoftteams", "Microsoft Teams", "Produtividade", 8, 2, "Chat e calendário Teams integrados.", "Sem auth", "soon", "Em breve"),
    ("mixpanel", "Mixpanel", "Analytics & BI", 8, 2, "Eventos de produto e funis Mixpanel.", "Sem auth", "soon", "Em breve"),
    ("n8n", "n8n", "Automação & iPaaS", 4, 3, "Workflows n8n self-hosted.", "Sem auth", "soon", "Em breve"),
    ("telegram", "Telegram", "Mensageiros", 8, 2, "Bot e inbox Telegram — via Composio toolkit.", "Sem auth", "soon", "Em breve"),
    ("trello", "Trello", "Produtividade", 8, 2, "Cards Trello sincronizados com tarefas HubFU.", "Sem auth", "soon", "Em breve"),
]

def js_str(s):
    return s.replace("\\", "\\\\").replace("'", "\\'")

lines = [
    "/* HubFU integrations catalog — generated by build-hubfu-integrations-data.py */",
    "const HUBFU_LOGO_SLUGS = " + json.dumps(LOGO) + ";",
    "const HUBFU_INTEGRATIONS = [",
]
for row in ITEMS:
    id_, name, cat, m1, m2, desc, auth, state, action = row
    slug = LOGO.get(id_)
    slug_js = f'"{slug}"' if slug else "null"
    lines.append(
        f"  {{ id:'{id_}', name:'{js_str(name)}', category:'{js_str(cat)}', "
        f"m1:{m1}, m2:{m2}, desc:'{js_str(desc)}', auth:'{auth}', state:'{state}', action:'{action}', slug:{slug_js} }},"
    )
lines.append("];")
lines.append(f"const HUBFU_INTEGRATIONS_COUNT = {len(ITEMS)};")

OUT.write_text("\n".join(lines) + "\n")
print(f"Wrote {len(ITEMS)} integrations → {OUT}")
