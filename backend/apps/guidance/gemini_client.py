"""
Gemini AI client for generating personalized wellness guidance.
Uses google-generativeai SDK with Gemini 1.5 Flash (free tier).
"""

import logging
from django.conf import settings

logger = logging.getLogger(__name__)

# Pre-written base tips as fallback when Gemini is unavailable
BASE_TIPS = {
    'menstrual': {
        'title': '🌸 Rest & Replenish',
        'content': (
            "Your body is working hard right now — be gentle with yourself. "
            "Warm herbal teas like ginger or chamomile can help ease discomfort. "
            "A heating pad on your lower abdomen is one of the most effective ways to relieve cramps naturally. "
            "Try gentle stretches or light yoga — avoid intense workouts if you're feeling heavy. "
            "Iron-rich foods like lentils, spinach, and dark chocolate (yes!) can help replenish what you lose. "
            "Rest is productive. Honor your body's need to slow down. 💕\n\n"
            "⚠️ This is general wellness guidance, not medical advice. "
            "For persistent or severe pain, please consult a doctor."
        )
    },
    'follicular': {
        'title': '🌱 Energy is Rising',
        'content': (
            "Welcome to your most energetic phase! Estrogen is climbing, and you may notice improved mood, "
            "sharper focus, and more motivation. This is a great time to start new projects or try a new workout. "
            "Your skin often glows during this phase — embrace it! "
            "Load up on leafy greens, eggs, and whole grains to fuel your rising energy. "
            "Socializing feels easier now — lean into connections. 💪\n\n"
            "⚠️ This is general wellness guidance, not medical advice."
        )
    },
    'ovulation': {
        'title': '✨ Peak Power',
        'content': (
            "You're at your peak! Your energy, confidence, and social drive are at their highest. "
            "This is ideal for challenging workouts, important conversations, or creative work. "
            "Your libido may be naturally higher — this is completely normal. "
            "Stay hydrated — aim for at least 8 glasses of water today. "
            "Zinc-rich foods like pumpkin seeds and chickpeas support your body now. "
            "Celebrate your strength! 🌟\n\n"
            "⚠️ This is general wellness guidance, not medical advice."
        )
    },
    'luteal': {
        'title': '🌙 Turn Inward',
        'content': (
            "Progesterone is rising, and it's normal to feel a little slower or more emotional. "
            "This is a time for reflection, not pushing. Gentle exercise like walking or swimming works beautifully. "
            "Cravings for carbs and sweets are real — complex carbs like sweet potato and oats can satisfy without a crash. "
            "Magnesium-rich foods (dark chocolate, avocado, bananas) can ease PMS symptoms. "
            "Prioritize sleep — your body is preparing for the next cycle. "
            "You are doing beautifully. 🫶\n\n"
            "⚠️ This is general wellness guidance, not medical advice."
        )
    }
}


def get_personalized_tip(phase: str, symptoms: list = None, lang: str = 'en') -> dict:
    """
    Returns a personalized wellness tip for the given phase and symptoms.
    Tries Gemini API first, falls back to pre-written base tips.
    """
    symptoms = symptoms or []

    try:
        return _get_gemini_tip(phase, symptoms, lang)
    except Exception as e:
        logger.warning(f"Gemini API failed, using fallback tip: {e}")
        return _get_fallback_tip(phase, symptoms, lang)


def _get_gemini_tip(phase: str, symptoms: list, lang: str) -> dict:
    """Calls Gemini 1.5 Flash to generate a personalized tip."""
    import google.generativeai as genai

    api_key = settings.GEMINI_API_KEY
    if not api_key:
        raise ValueError("GEMINI_API_KEY not set")

    genai.configure(api_key=api_key)
    model = genai.GenerativeModel('gemini-1.5-flash-latest')

    phase_descriptions = {
        'menstrual': 'menstrual/period phase (days 1-5)',
        'follicular': 'follicular phase (post-period, days 6-13)',
        'ovulation': 'ovulation phase (around day 14)',
        'luteal': 'luteal/pre-menstrual phase (days 15-28)',
    }

    symptom_text = ''
    if symptoms:
        symptom_text = f" The user has logged these symptoms today: {', '.join(symptoms)}."

    lang_instruction = "IMPORTANT: You MUST respond ENTIRELY in Bengali (বাংলা) language." if lang == 'bn' else "Respond in English."

    prompt = f"""You are a warm, supportive women's wellness companion in an app called Girls.
Generate a short, empowering daily wellness tip for a user in their {phase_descriptions.get(phase, phase)}.{symptom_text}

Rules:
- Keep it under 4 sentences.
- {lang_instruction}
- Tone: empathetic, uplifting, scientifically grounded but accessible.
- Is clearly labeled as general wellness guidance, NOT medical advice
- Includes a brief disclaimer: "For persistent or severe symptoms, please consult a doctor." (Translate this disclaimer to Bengali if responding in Bengali).

Format your response as:
TITLE: [a short, friendly title with an emoji]
CONTENT: [the actual tip text]"""

    response = model.generate_content(prompt)
    text = response.text.strip()

    # Parse response
    title = f"{phase.title()} Wellness Tip"
    content = text

    if 'TITLE:' in text and 'CONTENT:' in text:
        parts = text.split('CONTENT:', 1)
        title_part = parts[0].replace('TITLE:', '').strip()
        content_part = parts[1].strip() if len(parts) > 1 else text
        title = title_part
        content = content_part

    return {
        'title': title,
        'content': content,
        'source': 'gemini',
        'phase': phase,
    }


def _get_fallback_tip(phase: str, symptoms: list, lang: str) -> dict:
    """Returns a pre-written tip with symptom-specific additions."""
    base = BASE_TIPS.get(phase, BASE_TIPS['follicular'])
    content = base['content']
    title = base['title']

    if lang == 'bn':
        if phase == 'menstrual':
            title = '🌸 বিশ্রাম নিন'
            content = "আপনার শরীর এখন অনেক পরিশ্রম করছে, তাই নিজের প্রতি যত্নশীল হোন। আদা বা ক্যামোমাইল চা আপনার ব্যথা উপশমে সাহায্য করতে পারে। তলপেটে গরম সেঁক দিলে আরাম পাবেন। পর্যাপ্ত বিশ্রাম নিন এবং পুষ্টিকর খাবার খান।\n\n⚠️ এটি সাধারণ পরামর্শ, কোনো চিকিৎসা নয়। বেশি ব্যথা হলে ডাক্তারের পরামর্শ নিন।"
        elif phase == 'follicular':
            title = '🌱 নতুন শক্তি'
            content = "আপনার এনার্জি এখন বাড়তে শুরু করেছে! নতুন কিছু শুরু করার জন্য এটি দারুণ সময়। শাকসবজি ও পুষ্টিকর খাবার খান যা আপনার শরীরকে শক্তি জোগাবে।\n\n⚠️ এটি সাধারণ পরামর্শ, কোনো চিকিৎসা নয়।"
        elif phase == 'ovulation':
            title = '✨ দারুণ সময়'
            content = "আপনি এখন সবচেয়ে এনার্জেটিক! আপনার আত্মবিশ্বাস ও কাজ করার ক্ষমতা এখন সবচেয়ে বেশি। পর্যাপ্ত জল পান করুন এবং নিজেকে হাইড্রেটেড রাখুন।\n\n⚠️ এটি সাধারণ পরামর্শ, কোনো চিকিৎসা নয়।"
        elif phase == 'luteal':
            title = '🌙 নিজের যত্ন নিন'
            content = "এই সময়ে একটু ক্লান্ত বা আবেগপ্রবণ লাগা স্বাভাবিক। নিজেকে সময় দিন, বিশ্রাম নিন এবং হালকা ব্যায়াম করুন। মিষ্টি খাওয়ার ইচ্ছা হতে পারে, তবে স্বাস্থ্যকর খাবার বেছে নিন।\n\n⚠️ এটি সাধারণ পরামর্শ, কোনো চিকিৎসা নয়।"

    # Add symptom-specific additions
    symptom_additions = {
        'cramps': "\n\n💊 For your cramps: try a warm compress, gentle lower-back stretches, or magnesium-rich foods like dark chocolate and avocado.",
        'headache': "\n\n🧊 For your headache: stay hydrated, try a cold compress on your forehead, reduce screen time, and rest in a quiet space.",
        'bloating': "\n\n🌿 For bloating: avoid carbonated drinks and salty foods. Peppermint tea and gentle walks can help ease discomfort.",
        'mood_swings': "\n\n🧘 For mood swings: deep breathing, journaling your feelings, or a short walk outdoors can help regulate your emotions.",
        'fatigue': "\n\n😴 For fatigue: honor your need to rest. Iron-rich snacks like hummus or trail mix can give a gentle energy boost.",
        'nausea': "\n\n🍋 For nausea: try ginger tea, eat small frequent meals, and stay hydrated. Bland, easy-to-digest foods are your friend.",
    }

    for symptom in symptoms:
        if symptom in symptom_additions:
            content += symptom_additions[symptom]

    return {
        'title': title,
        'content': content,
        'source': 'fallback',
        'phase': phase,
    }
