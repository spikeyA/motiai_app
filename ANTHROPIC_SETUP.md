# Anthropic Claude API Setup Guide

## Overview

Your MotiAI app now uses **Anthropic's Claude API** for generating AI quotes instead of DeepAI. Claude is a more advanced language model that provides better quality quotes.

## Setup Instructions

### 1. Get Your Anthropic API Key

1. **Sign up for Anthropic**: Go to [console.anthropic.com](https://console.anthropic.com)
2. **Create an account** or log in
3. **Navigate to API Keys**: Go to the API Keys section
4. **Create a new API key**: Click "Create Key" and copy the key

### 2. Add API Key to Your App

Add your Anthropic API key to the `.env` file in your `motiai_app` directory:

```bash
DEEPAI_API_KEY=d5e360cf-8ebb-4b67-be6f-a453f736ef6d
ANTHROPIC_API_KEY=your_actual_anthropic_api_key_here
```

Replace `your_actual_anthropic_api_key_here` with your real API key.

### 3. Test the Integration

Run your app and check the console logs. You should see:
- `[Anthropic] Successfully generated AI quote: "..."` when working
- `[Anthropic] Authentication failed - check your API key` if the key is invalid
- `[Anthropic] Rate limit exceeded - try again later` if you hit rate limits

## API Details

- **Model**: `claude-3-haiku-20240307` (fast, cost-effective)
- **Max Tokens**: 150 (for quote generation)
- **Endpoint**: `https://api.anthropic.com/v1/messages`
- **Rate Limits**: Varies by plan (check your Anthropic dashboard)

## Troubleshooting

### Common Issues

1. **"Anthropic not configured - no API key found"**
   - Make sure your `.env` file contains `ANTHROPIC_API_KEY=your_key`
   - Restart the app after adding the key

2. **"Anthropic authentication failed"**
   - Check that your API key is correct
   - Ensure you have an active Anthropic account

3. **"Anthropic rate limit exceeded"**
   - Wait a moment and try again
   - Check your usage in the Anthropic dashboard

4. **App falls back to local quotes**
   - This is normal behavior when AI generation fails
   - The app gracefully falls back to your curated local quotes

## Benefits of Claude API

- **Better Quality**: More coherent and contextually appropriate quotes
- **Reliable**: More stable than DeepAI's text generator
- **Cost Effective**: Claude Haiku is very affordable
- **No Credit System**: Pay per use, no complex credit management

## Developer Controls

You can disable AI quotes entirely by setting:
```dart
HiveQuoteService.useAIQuotes = false;
```

This will make the app use only local quotes, which is perfect for development or when you want to conserve API usage.

## Migration from DeepAI

The app has been updated to use Anthropic instead of DeepAI. The main changes:
- Quote generation now uses Claude API
- Background image generation still uses DeepAI (unchanged)
- Error handling updated for Anthropic's response format
- Logging updated to show Anthropic status

Your existing DeepAI API key is still used for background image generation, so you can keep both keys in your `.env` file. 