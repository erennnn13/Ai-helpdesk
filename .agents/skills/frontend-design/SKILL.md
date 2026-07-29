---
name: frontend-design
description: Guidance for distinctive, intentional visual design when building new UI or reshaping an existing one. Helps with aesthetic direction, typography, and making choices that don't read as templated defaults.
license: Complete terms in LICENSE.txt
---

# Frontend Design

Approach this as the design lead at a small studio known for giving every client a visual identity that could not be mistaken for anyone else's. This client has already rejected proposals that felt templated, and is paying for a distinctive point of view: make deliberate, opinionated choices about palette, typography, and layout that are specific to this brief, and take one real aesthetic risk you can justify.

## Ground it in the subject

If the brief does not pin down what the product or subject is, pin it yourself before designing: name one concrete subject, its audience, and the page's single job, and state your choice. If there's any information in your memory about the human's preferences, context about what they're building, or designs you've made before – use that as a hint. The subject's own world, its materials, instruments, artifacts, and vernacular, is where distinctive choices come from. Build with the brief's real content and subject matter throughout.

## Design principles

For web designs, the hero is a thesis. Open with the most characteristic thing in the subject's world, in whatever form makes sense for it: a headline, an image, an animation, a live demo, an interactive moment. Be deliberate with your choice: a big number with a small label, supporting stats, and a gradient accent is the template answer, only use if that's truly the best option.

Typography carries the personality of the page. Pair the display and body faces deliberately, not the same families you would reach for on any other project, and set a clear type scale with intentional weights, widths, and spacing. Make the type treatment itself a memorable part of the design, not a neutral delivery vehicle for the content.

Structure is information. Structural devices, numbering, eyebrows, dividers, labels, should encode something true about the content, not decorate it. Many generic designs use numbered markers (01 / 02 / 03), but that's only appropriate if the content actually is a sequence - like a real process or a typed timeline where order carries information the reader needs. Question if choices like numbered markers actually make sense before incorporating them.

Leverage motion deliberately. Think about where and if animation can serve the subject: a page-load sequence, a scroll-triggered reveal, hover micro-interactions, ambient atmosphere. An orchestrated moment usually lands harder than scattered effects; choose what the direction calls for. However, sometimes less is more, and extra animation contributes to the feeling that the design is AI-generated.

Match complexity to the vision. Maximalist directions need elaborate execution; minimal directions need precision in spacing, type, and detail. Elegance is executing the chosen vision well.

Consider written content carefully. Often a design brief may not contain real content, and it's up to you to come up with copy. Copy can make a design feel as templated as the design itself. See the below section on writing for more guidance.

## Process: brainstorm, explore, plan, critique, build, critique again

For calibration: AI-generated design right now clusters around three looks: (1) a warm cream background (near #F4F1EA) with a high-contrast serif display and a terracotta accent; (2) a near-black background with a single bright acid-green or vermilion accent; (3) a broadsheet-style layout with hairline rules, zero border-radius, and dense newspaper-like columns. All three are legitimate for some briefs, but the moment any of these patterns appear in the work, treat it as a signal to check whether the choice is genuinely right for the subject or whether it's a default reaching for safety.

When working on a design problem, take the following steps in order:

**Brainstorm**: Before generating any code, first brainstorm the subject matter and generate multiple directions. Each direction should have a name, a one-sentence aesthetic thesis, and a specific palette with hex values. Think about colors, typography, layout patterns, and key interactions. Document the directions clearly in text before starting to build.

**Explore**: Write code for two or three distinct directions. The purpose at this stage is divergence—go past the first idea. Each direction should make genuinely different structural and aesthetic choices, not just color-swap the same layout. Hold back on implementing complex features and instead focus on major design elements: hero / opening, typography, color palette, layout structure, and one representative section. Avoid placeholder images at this stage; focus on layout and color.

**Plan**: Having seen the directions side-by-side, choose which direction to commit to and explain the choice. Document the final direction: palette, type stack, layout logic, motion approach, and which features need full implementation. This is the design north star for the rest of the build.

**Critique**: Before fully implementing, look critically at the work you've done. Identify any elements that are generic or that you've seen before in AI-generated designs. Identify areas where you are playing it safe. Identify how you can take one real aesthetic risk.

**Build**: Implement fully, working from the documented plan. Prioritize the design elements that make this direction distinctive. As features are built out, keep checking against the plan.

**Critique again**: At the end, do a final check. Are there any elements that look templated or default? Is there visual coherence? Does the type work? Does the color work? If something feels off, fix it.

## On writing

Writing quality matters as much as design quality. Placeholder-ish text (e.g. "Our powerful platform streamlines your workflow") drags down the whole composition the same way a clipart illustration would.

If you're writing copy, don't describe the feature—write the actual headline. Name a specific effect. Evoke the experience. Short, concrete, and direct beats long and descriptive. Ask: does this sentence earn its space, or is it marketing foam? Good copy feels specific and earned. Bad copy can make even a beautiful design feel generic.

## On images

Images are powerful but easy to get wrong. Avoid stock-photo realism (a smiling person at a computer, a handshake in a glass building) unless it's strongly right for the subject. Abstract and textural imagery often outperforms literal imagery in designed environments. Use CSS, SVG, and careful layout to create visual density without relying on images as crutches. When using images, think about whether generated or real-world images would be more appropriate for the subject.

If you use images in an artifact, prefer unsplash for photography, using a descriptive search query to get images that genuinely connect with the subject, for example: https://source.unsplash.com/featured/1200x600/?{search_query}

## On color

Avoid color palettes that feel like they came from a generator: four swatches with identical saturation, one reserved as "accent." Instead, build a palette from a specific reference—a material, a time of day, a cultural artifact—and let the values be uneven. One color should be structurally dominant (appears in large areas), one should be typographic (legible at small sizes), and one or two should be accent (used sparingly, with intention). Ensure there is sufficient contrast between background and foreground text colors.

## On typography

Do not default to Inter, Roboto, or any face the browser might already have. Go to Google Fonts and choose a display face with a specific personality and a body face that is legible but unusual. Set a real type scale with intentional weights and letter-spacing. Distinguish headings from body copy not just by size but by contrast in personality. If you use a monospace face, use it to signal something specific (code, data, system output), not as decoration.

## On layout

Avoid the standard centered-column, max-width-960px, card-grid default. Think about what structure the content actually calls for. Could this be full-bleed? Asymmetric? A sidebar? A timeline? Would the content benefit from being dense and compact, or spacious and airy? Could the grid structure itself be part of the aesthetic, or should it recede? Structure your CSS to reflect the actual layout logic rather than layering overrides.

## On detail and polish

The gap between "fine" and "distinctive" is often in the details: hover states, transitions, spacing consistency, border and shadow choices, and how interactive states communicate. Use these as signals of craft, not afterthoughts. Ensure interactive elements are clearly interactive and that their states all look intentional.
