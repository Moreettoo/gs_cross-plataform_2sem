# Painel de Inteligência Territorial

Global Solution 2026.2 - FIAP - Cross-Platform Application Development

## Integrantes

| Nome completo | RM |
|---|---|
| Enzo Moretto | 563655  |
| Lucas Scovini | 563355 |
| João Ivo |  |

## O que é

Um app em Flutter para um gestor público acompanhar três territórios (Centro Histórico, Vila Nova e Comunidade Rural Sul).

O app mostra:
- **Painel:** indicadores de água, energia, resíduos e serviços, com gráfico e previsão para 7 dias.
- **Alertas:** cada alerta tem justificativa, nível de confiança e limitações.
- **Decisões:** o gestor registra o que decidiu. O app nunca age sozinho.

## O que foi usado

- Navegação: barra com 4 abas e telas de detalhe.
- Estado: `provider`.
- API: Open-Meteo (clima).
- Salvamento no aparelho: `shared_preferences`.
- Formulário com validação: registro de decisão.
- Componentes próprios em `lib/widgets`.
- Acessibilidade: texto maior, alto contraste e leitor de tela.
- Privacidade: só dados agregados por bairro, nada de moradores.

## Fontes de dados

- **Clima:** [Open-Meteo](https://open-meteo.com/), que é gratuita e não precisa de chave.
- **Água, energia, resíduos e serviços:** dados inventados (sintéticos), gerados em `lib/services/gerador_dados.dart`.

## Como o alerta é calculado

Uma reta é traçada com os últimos 14 dias e prolongada por 7 dias. Se a previsão passar do limite, vira alerta. A confiança diz o quanto a reta se ajusta aos dados.

## Limitações

- O modelo é simples e não vê feriados nem eventos.
- Os dados de consumo são inventados.
- O limite de cada alerta é uma suposição.
- O clima é sempre de São Paulo.
- Confiança baixa quer dizer que é preciso confirmar em campo.

## Como rodar

Precisa do [Flutter](https://docs.flutter.dev/get-started/install).

```bash
flutter create . --platforms=web,android
flutter pub get
flutter run
```
