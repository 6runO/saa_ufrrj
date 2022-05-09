module Contrapartida
  MOTIVO1 = "REPF>1"
  MOTIVO2 = "100% RPM"
  MOTIVO3 = "REPF=1 e APR<50%"
  MOTIVO4 = "REPF=1 e REPM>0"
  MOTIVO5 = "REPF=1 e CH<240"
  MOTIVO6 = "CH Insuficiente"
  MOTIVO7 = "REPF=1, RPM=0, CH>=240 e APR>=50%"
  MOTIVO8 = "APR<50% (REPF=0)"

  def self.motivo(num_repf:, hrs_apr:, hrs_repm:, hrs_repf:, ratio_apr:, cr:, ira:, turno:)
    ch_min = (turno.length > 1) ? 180 : 120
    hrs_cursado = hrs_apr + hrs_repm + hrs_repf
    mtv1 = MOTIVO1 if num_repf > 1
    mtv2 = MOTIVO2 if (hrs_apr == 0 && hrs_repf == 0 && hrs_repm > 0)
    mtv3 = MOTIVO3 if (num_repf == 1 && ratio_apr < 0.5)
    mtv4 = MOTIVO4 if (num_repf == 1 && hrs_repm > 0)
    mtv5 = MOTIVO5 if (num_repf == 1 && hrs_cursado < 240)
    mtv6 = MOTIVO6 if hrs_cursado < ch_min
    mtv7 = MOTIVO7 if (num_repf == 1 && hrs_repm == 0 && hrs_cursado >= 240 && ratio_apr >= 0.5)
    mtv8 = MOTIVO8 if (num_repf == 0 && ratio_apr < 0.5)
    motivo = [mtv1, mtv2, mtv3, mtv4, mtv5, mtv6, mtv7, mtv8, mtv9]
    motivo = motivo.empty? ? "N/A" : motivo.compact.join('; ')
  end

  def self.resultado(motivo)
    cp1 = "Insatisfatório"
    cp2 = "Justificativa"
    cp3 = "Insatisfatório (Acompanhamento, se IRA/CR>=CRM")
    cp4 = "Satisfatório"
    if motivo = "N/A"
      contrapartida = cp4
    elsif motivo.include?(MOTIVO1) || motivo.include?(MOTIVO2) || motivo.include?(MOTIVO3)
      contrapartida = cp1
    elsif motivo.include?(MOTIVO4) || motivo.include?(MOTIVO5) || motivo.include?(MOTIVO6)
      contrapartida = cp1
    elsif motivo == MOTIVO7
      contrapartida = cp2
    elsif motivo == MOTIVO8
      contrapartida = cp3
    else
      contrapartida = cp4
    end
  end
end
