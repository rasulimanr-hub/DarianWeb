(function () {
    let audioContext;

    function getAudioContext() {
        const AudioContextClass = window.AudioContext || window.webkitAudioContext;
        if (!AudioContextClass) return null;
        if (!audioContext) audioContext = new AudioContextClass();
        return audioContext;
    }

    function playTone(context, frequency, endFrequency, startTime, duration, volume, type) {
        const oscillator = context.createOscillator();
        const gain = context.createGain();
        oscillator.type = type;
        oscillator.frequency.setValueAtTime(frequency, startTime);
        oscillator.frequency.exponentialRampToValueAtTime(endFrequency, startTime + duration);
        gain.gain.setValueAtTime(0.0001, startTime);
        gain.gain.exponentialRampToValueAtTime(volume, startTime + 0.015);
        gain.gain.exponentialRampToValueAtTime(0.0001, startTime + duration);
        oscillator.connect(gain);
        gain.connect(context.destination);
        oscillator.start(startTime);
        oscillator.stop(startTime + duration + 0.02);
        oscillator.addEventListener('ended', () => {
            oscillator.disconnect();
            gain.disconnect();
        }, { once: true });
    }

    function playSound(context, type) {
        const now = context.currentTime;
        if (type === 'enter') {
            playTone(context, 180, 440, now, 0.34, 0.5, 'sine');
            playTone(context, 420, 880, now + 0.06, 0.24, 0.236, 'triangle');
            playTone(context, 660, 990, now + 0.12, 0.18, 0.127, 'sine');
            return;
        }
        if (type === 'exit') {
            playTone(context, 520, 260, now, 0.3, 0.409, 'sine');
            playTone(context, 350, 175, now + 0.05, 0.28, 0.2, 'triangle');
            return;
        }
        if (type === 'section') {
            playTone(context, 310, 620, now, 0.23, 0.318, 'sine');
            playTone(context, 620, 830, now + 0.045, 0.16, 0.136, 'triangle');
            return;
        }
        playTone(context, 560, 760, now, 0.12, 0.227, 'sine');
    }

    document.addEventListener('click', event => {
        if (!(event.target instanceof Element)) return;
        const control = event.target.closest('button, [role="button"], .article-label, .book-label, .chess-label, .momagat-label');
        if (!control || control.matches(':disabled, [aria-disabled="true"]')) return;

        let sound = 'click';
        if (control.id === 'enter-space') {
            sound = 'enter';
        } else if (control.matches('.back-button')) {
            sound = 'exit';
        } else if (control.matches('.nav-links button')) {
            sound = 'section';
        } else if (control.matches('.drawer-article, .article-label, .book-label, .chess-label, .momagat-label')) {
            sound = 'enter';
        }

        try {
            const context = getAudioContext();
            if (!context) return;
            if (context.state === 'suspended') {
                context.resume().then(() => playSound(context, sound)).catch(error => {
                    console.warn('تعذر تشغيل مؤثرات الصوت:', error);
                });
            } else {
                playSound(context, sound);
            }
        } catch (error) {
            console.warn('تعذر تشغيل مؤثرات الصوت:', error);
        }
    }, true);
})();
