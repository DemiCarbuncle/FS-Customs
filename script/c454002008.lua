--Sky Striker Mobilize - Engaged!
--Scripted by DemiCarbuncle
local s,id=GetID()
function s.initial_effect(c)
	--Link summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetCondition(s.condition)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.announcecost)
	e1:SetTarget(s.target(TYPE_LINK,Card.IsLinkSummonable))
	e1:SetOperation(s.operation(TYPE_LINK,Card.IsLinkSummonable,function(sc,g,tp) Link.Send=5 Duel.LinkSummon(tp,sc,nil,g,#g,#g) end))
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
	c:RegisterEffect(e1)
	--xyz summon
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetTarget(s.target(TYPE_XYZ,Card.IsXyzSummonable))
	e2:SetOperation(s.operation(TYPE_XYZ,Card.IsXyzSummonable,function(sc,g,tp) Duel.XyzSummon(tp,sc,nil,g) end))
	c:RegisterEffect(e2)
end
s.listed_series={0x1115}
function s.announcecost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.counterfilter(c)
	return c:IsSetCard(0x1115) or not c:IsSummonLocation(LOCATION_EXTRA)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,1),nil)
	--lizard check
	aux.addTempLizardCheck(e:GetHandler(),tp,s.lizfilter)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x1115) and c:IsLocation(LOCATION_EXTRA)
end
function s.lizfilter(e,c)
	return not c:IsOriginalSetCard(0x1115)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.relfilter(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.matfilter(c,e,tp)
	return c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.filter(montype,chkfun)
	return function(c,mg,tp,chk)
		return c:IsSetCard(0x1115) and c:IsType(montype) and (not chk or Duel.GetLocationCountFromEx(tp,tp,mg,c)>0) and (not mg or chkfun(c,nil,mg,#mg,#mg))
	end
end
function s.rescon(exg,chkfun)
	return function(sg,e,tp,mg)
		local _1,_2=aux.dncheck(sg,e,tp,mg)
		return _1 and exg:IsExists(chkfun,1,nil,nil,sg,#sg,#sg),_2
	end
end
function s.target(montype,chkfun)
	return function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		local exg=Duel.GetMatchingGroup(s.filter(montype,chkfun),tp,LOCATION_EXTRA,0,nil,nil,tp)
		local cancelcon=s.rescon(exg,chkfun)
		if chkc then return chkc:IsControler(tp) and c:IsLocation(LOCATION_GRAVE) and chkc:IsCanBeSpecialSummoned(e,0,tp,false,false) and cancelcon(Group.FromCards(chkc)) end
		local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
		local min=math.min(math.min(Duel.GetLocationCount(tp,LOCATION_MZONE),Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and 1 or 99),1)
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft>2 then ft=2 end
		if chk==0 then return min>0 and Duel.IsPlayerCanSpecialSummonCount(tp,2)
			and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
			and aux.SelectUnselectGroup(mg,e,tp,min,ft,cancelcon,0) end
		local sg=aux.SelectUnselectGroup(mg,e,tp,min,ft,cancelcon,chk,tp,HINTMSG_SPSUMMON,cancelcon)
		Duel.SetTargetCard(sg)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,#sg,0,0)
	end
end
function s.operation(montype,chkfun,fun)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local g=Duel.GetTargetCards(e):Filter(s.relfilter,nil,e,tp)
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<#g or #g==0 or (Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and #g>1) then return end
		for tc in aux.Next(g) do
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			tc:RegisterEffect(e2)
		end
		Duel.SpecialSummonComplete()
		Duel.BreakEffect()
		local syng=Duel.GetMatchingGroup(s.filter(montype,chkfun),tp,LOCATION_EXTRA,0,nil,g,tp,true)
		if #syng>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local c=syng:Select(tp,1,1,nil):GetFirst()
			fun(c,g,tp)
		end
	end
end
