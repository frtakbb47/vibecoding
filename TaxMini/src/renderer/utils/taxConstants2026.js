/**
 * German Tax Constants for 2026 (Steuerjahr 2026)
 * Based on official German tax law and recent legislative changes
 *
 * Sources: Bundesfinanzministerium, Steuergesetze
 * Last Updated: January 2026
 */

export const TAX_YEAR = 2026;

// ============================================
// GRUNDFREIBETRÄGE (Basic Allowances)
// ============================================
export const BASIC_ALLOWANCES = {
    // Tax-free basic allowance (increases from €12,084 in 2025)
    grundfreibetrag: 12336,

    // Child allowance per child (both parents combined)
    kinderfreibetrag: 6828,

    // BEA-Freibetrag (care, education, training) per child
    beaFreibetrag: 2928,

    // Total child allowance per child (Kinderfreibetrag + BEA)
    totalChildAllowance: 9756,

    // Kindergeld (monthly child benefit) - choose between this OR Kinderfreibetrag
    kindergeldMonthly: 255,
};

// ============================================
// WERBUNGSKOSTEN (Work-Related Expenses)
// ============================================
export const WORK_EXPENSES = {
    // Automatic deduction if no receipts (Arbeitnehmer-Pauschbetrag)
    pauschbetrag: 1230,

    // Home office allowance
    homeOffice: {
        dailyRate: 6,           // €6 per day worked from home
        maxDays: 210,           // Maximum claimable days
        maxAmount: 1260,        // Maximum annual deduction (210 × €6)
    },

    // Commuting allowance (Entfernungspauschale)
    commuting: {
        rateFirst20km: 0.30,    // €0.30 per km for first 20km
        rateAbove20km: 0.38,    // €0.38 per km from 21st km onwards
        maxDays: 230,           // Maximum workdays for calculation
        publicTransportMax: null, // No cap - can claim actual costs if higher
    },

    // Double household (Doppelte Haushaltsführung)
    doubleHousehold: {
        maxRentMonthly: 1000,   // Max deductible rent in Germany
        maxRentAbroadMonthly: 2000, // NEW 2026: Cap for abroad locations
        familyVisits: 0.30,     // Per km for visits home
    },

    // Work equipment
    workEquipment: {
        immediateDeduction: 800, // Items up to €800 net can be fully deducted
        // Above €800: depreciate over useful life
    },

    // Professional training & development
    training: {
        fullyDeductible: true,  // No cap on work-related training
    },

    // Union dues - NEW for 2026: Now separately listed/emphasized
    unionDues: {
        fullyDeductible: true,
        separateEntry: true,    // Must be entered separately from 2026
    },

    // Job application costs
    applicationCosts: {
        perApplication: 8.50,   // Flat rate per application (with documents)
        perOnlineApplication: 2.50, // Online applications
    },

    // Bank account fees for salary account
    bankAccountFees: {
        flatRate: 16,           // If no receipts
    },
};

// ============================================
// SONDERAUSGABEN (Special Expenses)
// ============================================
export const SPECIAL_EXPENSES = {
    // Automatic deduction if no receipts
    pauschbetrag: 36,

    // Pension contributions (Vorsorgeaufwendungen)
    pension: {
        basisVorsorge: {
            maxSingle: 27566,   // Max deductible basis pension (2026)
            maxMarried: 55132,  // For married filing jointly
            deductiblePercent: 100, // Now 100% deductible since 2023
        },
    },

    // Insurance premiums
    insurance: {
        healthInsuranceBasic: true, // Fully deductible (Basisabsicherung)
        nursingCareInsurance: true, // Fully deductible
        otherInsurance: {
            maxSingle: 1900,    // For employees
            maxSelfEmployed: 2800, // For self-employed
        },
    },

    // Church tax - fully deductible
    churchTax: {
        fullyDeductible: true,
    },

    // Donations
    donations: {
        maxPercent: 20,         // Up to 20% of income deductible
        politicalParties: {
            directDeduction: 1650, // Direct tax reduction
            maxSingle: 1650,
            maxMarried: 3300,
        },
    },

    // Private school fees
    privateSchoolFees: {
        maxPercent: 30,         // 30% of fees deductible
        maxAmount: 5000,        // Up to €5,000 per year
    },

    // Alimony (Unterhalt)
    alimony: {
        maxDeductible: 13805,   // Maximum for Realsplitting
        // Note: Recipient must agree and declare as income
    },

    // Training costs (Berufsausbildung)
    firstDegree: {
        maxAmount: 6000,        // First degree/Ausbildung (not Werbungskosten!)
        isWerbungskosten: false, // Treated as Sonderausgaben
    },
    secondDegree: {
        isWerbungskosten: true, // Full deduction as work expenses
        noLimit: true,          // No cap for second degree
    },
};

// ============================================
// STUDENTS & EDUCATION
// ============================================
export const STUDENT_DEDUCTIONS = {
    // First degree/Erstausbildung
    firstDegree: {
        maxAnnual: 6000,
        type: 'Sonderausgaben',  // Special expenses, no loss carryforward
        examples: ['Bachelor (first degree)', 'Ausbildung', 'First university study'],
    },

    // Second degree/Zweitausbildung
    secondDegree: {
        unlimited: true,
        type: 'Werbungskosten',  // Work expenses, allows loss carryforward!
        examples: ['Master degree', 'Second Bachelor', 'PhD', 'Training after first Ausbildung'],
    },

    // Student-specific deductions
    typicalDeductions: [
        { name: 'Semester fees', amount: 'Full amount' },
        { name: 'Textbooks & materials', amount: 'Full amount' },
        { name: 'Computer/Laptop', amount: 'Up to €800 immediate or depreciate' },
        { name: 'Software (Office, etc.)', amount: 'Full amount' },
        { name: 'Commute to university', amount: '€0.30-0.38/km' },
        { name: 'Second household near uni', amount: 'Rent + travel costs' },
        { name: 'Study trips/excursions', amount: 'Full amount' },
        { name: 'Printer, paper, supplies', amount: 'Full amount' },
        { name: 'Internet (work portion)', amount: '~50% or €20/month' },
    ],

    // IMPORTANT: Loss carryforward for second degree
    lossCarryforward: {
        available: true,        // For Zweitausbildung only
        duration: 'unlimited',  // Carries forward until used
        benefit: 'Reduces taxes when employed after graduation',
    },
};

// ============================================
// EXPATS & INTERNATIONAL
// ============================================
export const EXPAT_PROVISIONS = {
    // Tax residency rules
    taxResidency: {
        days183Rule: 183,       // Present 183+ days = tax resident
        habitualAbode: true,    // Or if Germany is "Lebensmittelpunkt"
    },

    // Double taxation treaties
    taxTreaties: {
        exists: true,
        commonCountries: ['USA', 'UK', 'France', 'Italy', 'Spain', 'India', 'China', 'Canada'],
        effect: 'Foreign income may be exempt or credited',
    },

    // Foreign income
    foreignIncome: {
        progressionsvorbehalt: true, // Exempt income affects tax rate
        worldwideIncome: true,       // Must declare if resident
    },

    // Moving costs from abroad
    relocationCosts: {
        deductible: true,       // If for work reasons
        examples: ['Shipping costs', 'Travel', 'Temporary housing', 'Language courses (if work-related)'],
    },
};

// ============================================
// IMPORTANT DEADLINES (for 2026 tax year)
// ============================================
export const DEADLINES_2026 = {
    // Employer documents
    lohnsteuerbescheinigung: {
        date: '2027-02-28',
        description: 'Employer must provide wage tax certificate',
    },

    // Filing deadlines
    selfFiling: {
        date: '2027-07-31',
        description: 'Deadline if filing yourself (no advisor)',
    },

    withAdvisor: {
        date: '2028-02-28',     // Extended deadline with Steuerberater
        description: 'Deadline when using tax advisor (Steuerberater)',
    },

    voluntaryFiling: {
        date: '2030-12-31',     // 4 years for voluntary returns
        description: 'Last day for voluntary tax return (4-year window)',
    },

    // Quarterly prepayments (for those required to pay)
    prepayments: [
        { date: '2026-03-10', quarter: 'Q1' },
        { date: '2026-06-10', quarter: 'Q2' },
        { date: '2026-09-10', quarter: 'Q3' },
        { date: '2026-12-10', quarter: 'Q4' },
    ],
};

// ============================================
// TAX BRACKETS & RATES (2026)
// ============================================
export const TAX_BRACKETS = {
    // Zone 1: Tax-free
    zone1: {
        upTo: 12336,            // Grundfreibetrag
        rate: 0,
    },

    // Zone 2: Progressive (14% - 24%)
    zone2: {
        from: 12337,
        upTo: 17443,            // Approximate threshold
        startRate: 14,
        endRate: 24,
    },

    // Zone 3: Progressive (24% - 42%)
    zone3: {
        from: 17444,
        upTo: 68480,            // Approximate threshold
        startRate: 24,
        endRate: 42,
    },

    // Zone 4: 42% flat
    zone4: {
        from: 68481,
        upTo: 277825,
        rate: 42,
    },

    // Zone 5: Top rate (Reichensteuer)
    zone5: {
        from: 277826,
        rate: 45,
    },

    // Solidarity surcharge (largely eliminated but still applies to high earners)
    solidaritaetszuschlag: {
        rate: 5.5,
        exemptUpTo: 18130,      // No Soli if tax is below this (married: 36260)
    },
};

// ============================================
// AVERAGE REFUND STATISTICS
// ============================================
export const STATISTICS = {
    averageRefund: 1095,        // Average refund in Germany (employees)
    percentReceiveRefund: 88,   // % of filers who get money back
    averageTimeMinutes: 20,     // Average time to file with TaxMini
    studentsAverageRefund: 950, // Students often recover taxes from minijobs etc.
};

// ============================================
// NEW IN 2026
// ============================================
export const NEW_IN_2026 = [
    {
        category: 'Grundfreibetrag',
        change: 'Increased from €12,084 to €12,336',
        benefit: 'More income remains tax-free',
    },
    {
        category: 'Kindergeld',
        change: 'Increased to €255/month per child',
        benefit: 'Higher family support',
    },
    {
        category: 'Kinderfreibetrag',
        change: 'Increased to €6,828 per child',
        benefit: 'Higher deduction for families',
    },
    {
        category: 'Doppelte Haushaltsführung (Abroad)',
        change: 'NEW: €2,000/month cap for locations abroad',
        benefit: 'Still generous for international workers',
    },
    {
        category: 'Gewerkschaftsbeiträge',
        change: 'Now entered separately in ELSTER',
        benefit: 'Better visibility, same tax benefit',
    },
    {
        category: 'E-Sport',
        change: 'Now recognized as gemeinnützig (non-profit eligible)',
        benefit: 'E-sports clubs can issue donation receipts',
    },
    {
        category: 'Photovoltaik',
        change: 'Expanded VAT exemption for installations',
        benefit: 'Cheaper solar panel installations',
    },
];

// ============================================
// HELPER FUNCTIONS
// ============================================

/**
 * Calculate estimated tax using 2026 formula
 * @param {number} taxableIncome - Income after deductions and Grundfreibetrag
 * @returns {number} Estimated tax amount
 */
export function calculateTax2026(taxableIncome) {
    if (taxableIncome <= 0) return 0;

    const x = taxableIncome;
    const grundfreibetrag = BASIC_ALLOWANCES.grundfreibetrag;

    // Zone 1: Tax-free
    if (x <= grundfreibetrag) {
        return 0;
    }

    // Zone 2: First progressive zone (approximately 14-24%)
    if (x <= 17443) {
        const y = (x - grundfreibetrag) / 10000;
        return Math.round((1004.25 * y + 1400) * y);
    }

    // Zone 3: Second progressive zone (approximately 24-42%)
    if (x <= 68480) {
        const z = (x - 17443) / 10000;
        return Math.round((208.85 * z + 2397) * z + 938.24);
    }

    // Zone 4: 42% rate
    if (x <= 277825) {
        return Math.round(0.42 * x - 9972.98);
    }

    // Zone 5: 45% top rate (Reichensteuer)
    return Math.round(0.45 * x - 18307.73);
}

/**
 * Calculate commuting deduction
 * @param {number} distance - One-way distance in km
 * @param {number} workdays - Number of workdays (max 230)
 * @returns {number} Annual commuting deduction
 */
export function calculateCommutingDeduction(distance, workdays = 230) {
    const effectiveWorkdays = Math.min(workdays, WORK_EXPENSES.commuting.maxDays);

    if (distance <= 20) {
        return distance * WORK_EXPENSES.commuting.rateFirst20km * effectiveWorkdays;
    }

    const first20km = 20 * WORK_EXPENSES.commuting.rateFirst20km * effectiveWorkdays;
    const beyondKm = (distance - 20) * WORK_EXPENSES.commuting.rateAbove20km * effectiveWorkdays;

    return first20km + beyondKm;
}

/**
 * Calculate home office deduction
 * @param {number} days - Number of days worked from home
 * @returns {number} Home office deduction amount
 */
export function calculateHomeOfficeDeduction(days) {
    const effectiveDays = Math.min(days, WORK_EXPENSES.homeOffice.maxDays);
    return Math.min(
        effectiveDays * WORK_EXPENSES.homeOffice.dailyRate,
        WORK_EXPENSES.homeOffice.maxAmount
    );
}

/**
 * Get marginal tax rate for given income
 * @param {number} taxableIncome - Taxable income
 * @returns {number} Marginal tax rate as percentage
 */
export function getMarginalTaxRate(taxableIncome) {
    if (taxableIncome <= BASIC_ALLOWANCES.grundfreibetrag) return 0;
    if (taxableIncome <= 17443) return 24;
    if (taxableIncome <= 68480) return 42;
    if (taxableIncome <= 277825) return 42;
    return 45;
}

export default {
    TAX_YEAR,
    BASIC_ALLOWANCES,
    WORK_EXPENSES,
    SPECIAL_EXPENSES,
    STUDENT_DEDUCTIONS,
    EXPAT_PROVISIONS,
    DEADLINES_2026,
    TAX_BRACKETS,
    STATISTICS,
    NEW_IN_2026,
    calculateTax2026,
    calculateCommutingDeduction,
    calculateHomeOfficeDeduction,
    getMarginalTaxRate,
};
