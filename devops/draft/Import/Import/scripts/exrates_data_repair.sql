   COMMENT ON TABLE "TSD_EXRATES_TA1"."PRDT_PRICING"  IS 'Type de taux (ex: coût de fonds, taux d''assurance vie, taux affiché, taux de perte)';
  CREATE INDEX "TSD_EXRATES_TA1"."FK_PRDT_PRICING_CONDTN_01" ON "TSD_EXRATES_TA1"."PRDT_PRICING" ("PRDT_CONDITION_ID") 
  ;
  CREATE INDEX "TSD_EXRATES_TA1"."FK_PRDT_PRICING_REF_RATE_01" ON "TSD_EXRATES_TA1"."PRDT_PRICING" ("REF_RATE_ID") 
  ;
 
  ALTER TABLE "TSD_EXRATES_TA1"."PRDT_PRICING" ADD CONSTRAINT "PK_PRDT_PRICING" PRIMARY KEY ("PRDT_CONDITION_ID", "PRDT_PRICING_TYPE_CD", "PRDT_PRICING_CURRENCY_CD", "PRDT_PRICING_EFFCTV_DT") RELY
  USING INDEX  ENABLE;