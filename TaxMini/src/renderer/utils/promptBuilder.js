/**
 * Builds a comprehensive "Mega Prompt" for Gemini to analyze German tax documents
 * This is the secret sauce - a well-engineered prompt for accurate tax analysis
 */

// German Tax Constants - keep in sync with Wizard.jsx
const TAX_CONSTANTS = {
    2025: {
        grundfreibetrag: 11784,
        arbeitnehmerPauschbetrag: 1230,
        homeOfficePerDay: 6,
        homeOfficeMaxDays: 210,
        pendlerFirst20km: 0.30,
        pendlerBeyond20km: 0.38,
        sonderausgabenPauschbetrag: 36,
        kirchensteuerRate: { bayern: 8, other: 9 },
    },
    2024: {
        grundfreibetrag: 11604,
        arbeitnehmerPauschbetrag: 1230,
        homeOfficePerDay: 6,
        homeOfficeMaxDays: 210,
        pendlerFirst20km: 0.30,
        pendlerBeyond20km: 0.38,
        sonderausgabenPauschbetrag: 36,
        kirchensteuerRate: { bayern: 8, other: 9 },
    },
    2023: {
        grundfreibetrag: 10908,
        arbeitnehmerPauschbetrag: 1230,
        homeOfficePerDay: 6,
        homeOfficeMaxDays: 210,
        pendlerFirst20km: 0.30,
        pendlerBeyond20km: 0.38,
        sonderausgabenPauschbetrag: 36,
        kirchensteuerRate: { bayern: 8, other: 9 },
    },
};

export function buildTaxPrompt(taxData) {
    const { year, profile, income, employment, deductions, extractedText } = taxData;
    const constants = TAX_CONSTANTS[year] || TAX_CONSTANTS[2025];

    // Combine all extracted text
    const documentTexts = Object.entries(extractedText)
        .filter(([_, data]) => data.text && data.text.length > 0)
        .map(([path, data]) => {
            const fileName = path.split(/[/\\]/).pop();
            return `\n--- DOCUMENT: ${fileName} ---\n${data.text}\n--- END DOCUMENT ---`;
        })
        .join('\n');

    if (!documentTexts) {
        return null;
    }

    // Build profile context
    const profileContext = buildProfileContext(profile);
    const incomeContext = buildIncomeContext(income);
    const employmentContext = buildEmploymentContext(employment);
    const deductionsContext = buildDeductionsContext(deductions, year);

    const prompt = `
You are a German Tax Expert (Steuerberater) assistant. Your task is to analyze the provided documents and extract all relevant tax information for a German income tax return (Einkommensteuererklärung) for the year ${year}.

## GERMAN TAX LAW CONSTANTS FOR ${year}
- Grundfreibetrag (basic tax-free allowance): €${constants.grundfreibetrag}
- Arbeitnehmer-Pauschbetrag (employee lump sum): €${constants.arbeitnehmerPauschbetrag}
- Home Office: €${constants.homeOfficePerDay}/day, max ${constants.homeOfficeMaxDays} days = €${constants.homeOfficePerDay * constants.homeOfficeMaxDays}
- Pendlerpauschale: €${constants.pendlerFirst20km}/km (first 20km), €${constants.pendlerBeyond20km}/km (beyond)
- Sonderausgaben-Pauschbetrag: €${constants.sonderausgabenPauschbetrag}
- Church tax (Kirchensteuer): ${constants.kirchensteuerRate.bayern}% in Bavaria, ${constants.kirchensteuerRate.other}% elsewhere

## USER PROFILE
${profileContext}

## INCOME ESTIMATE (provided by user)
${incomeContext}

## EMPLOYMENT SITUATION
${employmentContext}

## POTENTIAL DEDUCTIONS TO LOOK FOR
${deductionsContext}

## EXTRACTED DOCUMENT CONTENT
The following text was extracted from the user's uploaded documents:
${documentTexts}

## YOUR TASK
Analyze ALL provided documents carefully and extract:

1. **Income Data (Einkommen)**
   - Gross salary (Bruttolohn)
   - Net salary (Nettolohn)
   - Tax already paid (Lohnsteuer)
   - Social security contributions (Sozialversicherungsbeiträge)
   - Church tax if applicable (Kirchensteuer)
   - Solidarity surcharge (Solidaritätszuschlag)

2. **Deductions (Werbungskosten)**
   - Work equipment expenses
   - Commuting costs (Pendlerpauschale)
   - Home office days
   - Professional development costs
   - Any other work-related expenses

3. **Special Expenses (Sonderausgaben)**
   - Insurance premiums
   - Donations
   - Other special expenses

4. **Tax Calculation**
   - Calculate estimated tax refund or payment due
   - Show your calculation steps

5. **Missing Information**
   - List any documents that seem to be missing
   - Note any unclear or incomplete data

## RESPONSE FORMAT
Return ONLY a valid JSON object with this exact structure (no markdown, no code blocks, just pure JSON):

{
  "taxYear": ${year},
  "income": {
    "grossSalary": 0,
    "netSalary": 0,
    "taxPaid": 0,
    "churchTax": 0,
    "solidaritySurcharge": 0,
    "socialSecurity": {
      "health": 0,
      "pension": 0,
      "unemployment": 0,
      "care": 0
    }
  },
  "deductions": {
    "workEquipment": { "amount": 0, "items": [] },
    "commuting": { "amount": 0, "distance": 0, "days": 0 },
    "homeOffice": { "amount": 0, "days": 0 },
    "professionalDevelopment": { "amount": 0, "items": [] },
    "other": { "amount": 0, "items": [] },
    "totalDeductions": 0
  },
  "specialExpenses": {
    "insurances": { "amount": 0, "items": [] },
    "donations": { "amount": 0, "items": [] },
    "other": { "amount": 0, "items": [] },
    "totalSpecialExpenses": 0
  },
  "calculation": {
    "taxableIncome": 0,
    "expectedTax": 0,
    "taxAlreadyPaid": 0,
    "estimatedRefund": 0,
    "steps": []
  },
  "missingDocuments": [],
  "warnings": [],
  "summary": ""
}

Important:
- All monetary values should be numbers (not strings)
- Use 0 if a value cannot be determined
- Be conservative with estimates
- Include clear explanations in the "steps" array
- The "summary" should be a brief 2-3 sentence overview in English
`.trim();

    return prompt;
}

function buildProfileContext(profile) {
    const lines = [];

    const statusMap = {
        single: 'Single (Alleinstehend)',
        married: 'Married (Verheiratet)',
        separated: 'Separated (Getrennt)',
    };

    lines.push(`- Marital Status: ${statusMap[profile.maritalStatus] || 'Not specified'}`);

    if (profile.isStudent) {
        lines.push('- Status: Student');
    }

    if (profile.isExpat) {
        lines.push(`- Expat: Yes (arrived in Germany: ${profile.arrivalYear || 'unknown'})`);
    }

    if (profile.hasChildren) {
        lines.push('- Has children: Yes');
    }

    if (profile.payChurchTax) {
        lines.push(`- Pays church tax: Yes (${profile.churchTaxState === 'bayern' ? 'Bavaria - 8%' : 'Other state - 9%'})`);
    }

    if (profile.taxId) {
        lines.push(`- Tax ID: ${profile.taxId}`);
    }

    return lines.join('\n') || '- No profile information provided';
}

function buildIncomeContext(income) {
    if (!income) return '- No income estimate provided';

    const lines = [];

    if (income.estimatedGross) {
        lines.push(`- Estimated gross salary: €${parseInt(income.estimatedGross).toLocaleString()}`);
    }

    if (income.estimatedTaxPaid) {
        lines.push(`- Estimated tax already paid: €${parseInt(income.estimatedTaxPaid).toLocaleString()}`);
    }

    if (income.hadOtherIncome) {
        lines.push('- Had other income: Yes (investments, rental, etc.)');
    }

    return lines.join('\n') || '- No income estimate provided';
}

function buildEmploymentContext(employment) {
    const lines = [];

    const typeMap = {
        employed: 'Regular Employment (Angestellt)',
        minijob: 'Minijob (Geringfügige Beschäftigung)',
    };

    lines.push(`- Employment Type: ${typeMap[employment.type] || 'Not specified'}`);

    if (employment.hasMultipleJobs) {
        lines.push('- Multiple jobs in this year: Yes');
    }

    if (employment.workedFromHome) {
        lines.push(`- Worked from home: Yes (approximately ${employment.homeOfficeDays} days)`);
    }

    return lines.join('\n') || '- No employment information provided';
}

function buildDeductionsContext(deductions, year) {
    const constants = TAX_CONSTANTS[year] || TAX_CONSTANTS[2025];
    const items = [];

    if (deductions.workEquipment) {
        items.push(`Work equipment (computer, desk, chair, etc.)${deductions.workEquipmentAmount ? ` - estimated €${deductions.workEquipmentAmount}` : ''}`);
    }

    if (deductions.professionalLiterature) {
        items.push('Professional literature and courses');
    }

    if (deductions.workClothing) {
        items.push('Work clothing and uniforms');
    }

    if (deductions.commuting) {
        const distance = deductions.commuteDistance || 0;
        const days = deductions.commuteDays || 220;
        const first20 = Math.min(distance, 20) * constants.pendlerFirst20km;
        const beyond20 = Math.max(0, distance - 20) * constants.pendlerBeyond20km;
        const yearlyAmount = Math.round((first20 + beyond20) * days);
        items.push(`Commuting to work (${distance} km one-way, ${days} days = ~€${yearlyAmount} Pendlerpauschale)`);
    }

    if (deductions.movingExpenses) {
        items.push('Job-related moving expenses');
    }

    if (deductions.insurances) {
        items.push('Insurance premiums (health, liability, etc.)');
    }

    if (deductions.donations) {
        items.push('Charitable donations');
    }

    const contextText = items.length > 0
        ? `Look for these expense categories in the documents:\n${items.map(i => `- ${i}`).join('\n')}`
        : 'No specific deductions indicated by user';

    return `${contextText}\n\nNote: The Arbeitnehmer-Pauschbetrag of €${constants.arbeitnehmerPauschbetrag} is automatically applied if actual Werbungskosten are lower.`;
}

/**
 * Validates and parses the JSON response from Gemini
 * With multiple fallback strategies for robust parsing
 */
export function parseGeminiResponse(responseText) {
    try {
        // Try to extract JSON from the response
        let jsonStr = responseText.trim();

        // Strategy 1: Remove markdown code blocks if present
        if (jsonStr.startsWith('```json')) {
            jsonStr = jsonStr.slice(7);
        } else if (jsonStr.startsWith('```')) {
            jsonStr = jsonStr.slice(3);
        }
        if (jsonStr.endsWith('```')) {
            jsonStr = jsonStr.slice(0, -3);
        }
        jsonStr = jsonStr.trim();

        // Strategy 2: Find JSON object boundaries
        const firstBrace = jsonStr.indexOf('{');
        const lastBrace = jsonStr.lastIndexOf('}');
        if (firstBrace !== -1 && lastBrace !== -1 && lastBrace > firstBrace) {
            jsonStr = jsonStr.slice(firstBrace, lastBrace + 1);
        }

        // Strategy 3: Fix common JSON issues
        jsonStr = jsonStr
            .replace(/,\s*}/g, '}')  // Remove trailing commas before }
            .replace(/,\s*]/g, ']')  // Remove trailing commas before ]
            .replace(/'/g, '"')       // Replace single quotes with double
            .replace(/\n/g, ' ')      // Remove newlines that might break strings
            .replace(/\t/g, ' ');     // Remove tabs

        // Parse JSON
        const data = JSON.parse(jsonStr);

        // Validate and sanitize the data
        const sanitizedData = sanitizeTaxData(data);

        // Validate required fields
        if (!sanitizedData.income || !sanitizedData.calculation) {
            throw new Error('Missing required fields in response (income or calculation)');
        }

        // Validate numeric values are reasonable
        const validationErrors = validateTaxData(sanitizedData);
        if (validationErrors.length > 0) {
            // Add warnings but don't fail
            sanitizedData.warnings = [
                ...(sanitizedData.warnings || []),
                ...validationErrors
            ];
        }

        return {
            success: true,
            data: sanitizedData,
        };
    } catch (error) {
        // Try to provide helpful error message
        let errorMessage = error.message;

        if (error.message.includes('Unexpected token')) {
            errorMessage = 'Invalid JSON format. Make sure to copy the complete response from Gemini.';
        } else if (error.message.includes('Missing required fields')) {
            errorMessage = 'Response is missing required tax data. Please ask Gemini to regenerate.';
        }

        return {
            success: false,
            error: errorMessage,
            rawResponse: responseText,
        };
    }
}

/**
 * Sanitize and normalize tax data to ensure all fields exist with proper types
 */
function sanitizeTaxData(data) {
    return {
        taxYear: data.taxYear || new Date().getFullYear() - 1,
        income: {
            grossSalary: toNumber(data.income?.grossSalary),
            netSalary: toNumber(data.income?.netSalary),
            taxPaid: toNumber(data.income?.taxPaid),
            churchTax: toNumber(data.income?.churchTax),
            solidaritySurcharge: toNumber(data.income?.solidaritySurcharge),
            socialSecurity: {
                health: toNumber(data.income?.socialSecurity?.health),
                pension: toNumber(data.income?.socialSecurity?.pension),
                unemployment: toNumber(data.income?.socialSecurity?.unemployment),
                care: toNumber(data.income?.socialSecurity?.care),
            },
        },
        deductions: {
            workEquipment: {
                amount: toNumber(data.deductions?.workEquipment?.amount),
                items: data.deductions?.workEquipment?.items || [],
            },
            commuting: {
                amount: toNumber(data.deductions?.commuting?.amount),
                distance: toNumber(data.deductions?.commuting?.distance),
                days: toNumber(data.deductions?.commuting?.days),
            },
            homeOffice: {
                amount: toNumber(data.deductions?.homeOffice?.amount),
                days: toNumber(data.deductions?.homeOffice?.days),
            },
            professionalDevelopment: {
                amount: toNumber(data.deductions?.professionalDevelopment?.amount),
                items: data.deductions?.professionalDevelopment?.items || [],
            },
            other: {
                amount: toNumber(data.deductions?.other?.amount),
                items: data.deductions?.other?.items || [],
            },
            totalDeductions: toNumber(data.deductions?.totalDeductions),
        },
        specialExpenses: {
            insurances: {
                amount: toNumber(data.specialExpenses?.insurances?.amount),
                items: data.specialExpenses?.insurances?.items || [],
            },
            donations: {
                amount: toNumber(data.specialExpenses?.donations?.amount),
                items: data.specialExpenses?.donations?.items || [],
            },
            other: {
                amount: toNumber(data.specialExpenses?.other?.amount),
                items: data.specialExpenses?.other?.items || [],
            },
            totalSpecialExpenses: toNumber(data.specialExpenses?.totalSpecialExpenses),
        },
        calculation: {
            taxableIncome: toNumber(data.calculation?.taxableIncome),
            expectedTax: toNumber(data.calculation?.expectedTax),
            taxAlreadyPaid: toNumber(data.calculation?.taxAlreadyPaid),
            estimatedRefund: toNumber(data.calculation?.estimatedRefund),
            steps: data.calculation?.steps || [],
        },
        missingDocuments: data.missingDocuments || [],
        warnings: data.warnings || [],
        summary: data.summary || 'Tax analysis completed.',
    };
}

/**
 * Convert value to number, handling various input types
 */
function toNumber(value) {
    if (typeof value === 'number') return value;
    if (typeof value === 'string') {
        // Remove currency symbols and thousands separators
        const cleaned = value.replace(/[€$,\s]/g, '').replace(',', '.');
        const num = parseFloat(cleaned);
        return isNaN(num) ? 0 : num;
    }
    return 0;
}

/**
 * Validate tax data for common errors
 */
function validateTaxData(data) {
    const errors = [];

    // Check for unreasonably high values
    if (data.income.grossSalary > 500000) {
        errors.push('Gross salary seems unusually high. Please verify.');
    }

    // Check if tax paid is more than gross salary
    if (data.income.taxPaid > data.income.grossSalary * 0.5) {
        errors.push('Tax paid seems higher than expected (>50% of gross). Please verify.');
    }

    // Check if refund is larger than tax paid
    if (data.calculation.estimatedRefund > data.income.taxPaid) {
        errors.push('Estimated refund cannot exceed tax already paid. Values adjusted.');
        data.calculation.estimatedRefund = Math.min(
            data.calculation.estimatedRefund,
            data.income.taxPaid
        );
    }

    // Check for negative values that should be positive
    if (data.income.grossSalary < 0) {
        errors.push('Gross salary cannot be negative. Set to 0.');
        data.income.grossSalary = 0;
    }

    // Recalculate total deductions if it seems wrong
    const calculatedTotal =
        data.deductions.workEquipment.amount +
        data.deductions.commuting.amount +
        data.deductions.homeOffice.amount +
        data.deductions.professionalDevelopment.amount +
        data.deductions.other.amount;

    if (Math.abs(calculatedTotal - data.deductions.totalDeductions) > 10) {
        data.deductions.totalDeductions = calculatedTotal;
    }

    return errors;
}

/**
 * Formats currency for display
 */
export function formatCurrency(amount) {
    return new Intl.NumberFormat('de-DE', {
        style: 'currency',
        currency: 'EUR',
    }).format(amount || 0);
}

/**
 * Detect document type from filename and content
 */
export function detectDocumentType(fileName, text) {
    const lowerName = fileName.toLowerCase();
    const lowerText = (text || '').toLowerCase();

    // Lohnsteuerbescheinigung (annual tax statement from employer)
    if (lowerName.includes('lohnsteuer') || lowerText.includes('lohnsteuerbescheinigung') ||
        lowerText.includes('ausdruck der elektronischen lohnsteuerbescheinigung')) {
        return { type: 'lohnsteuerbescheinigung', priority: 1, label: 'Tax Statement' };
    }

    // Gehaltsabrechnung (monthly payslip)
    if (lowerName.includes('gehaltsabrechnung') || lowerName.includes('payslip') ||
        lowerText.includes('gehaltsabrechnung') || lowerText.includes('entgeltabrechnung')) {
        return { type: 'payslip', priority: 2, label: 'Payslip' };
    }

    // Receipt/Invoice
    if (lowerName.includes('rechnung') || lowerName.includes('invoice') || lowerName.includes('receipt') ||
        lowerText.includes('rechnung') || lowerText.includes('invoice')) {
        return { type: 'receipt', priority: 3, label: 'Receipt' };
    }

    // Donation receipt
    if (lowerName.includes('spende') || lowerText.includes('spendenquittung') ||
        lowerText.includes('zuwendungsbestätigung')) {
        return { type: 'donation', priority: 4, label: 'Donation Receipt' };
    }

    // Insurance
    if (lowerName.includes('versicherung') || lowerText.includes('versicherung') ||
        lowerText.includes('beitrag')) {
        return { type: 'insurance', priority: 5, label: 'Insurance' };
    }

    return { type: 'other', priority: 10, label: 'Document' };
}
